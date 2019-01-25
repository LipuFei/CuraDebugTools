from collections import OrderedDict
import os
import sys
from typing import TYPE_CHECKING, Union, Dict, Any

import yaml

from UM.Logger import Logger

from cura.CuraApplication import CuraApplication
from cura.Settings.CuraStackBuilder import CuraStackBuilder

if TYPE_CHECKING:
    from cura.Settings.GlobalStack import GlobalStack
    from cura.Settings.ExtruderStack import ExtruderStack


class MachineSettingsDumper:

    def __init__(self) -> None:
        self._application = CuraApplication.getInstance()

    def dumpAllMachinesDefaultSettings(self, output_dir: str) -> None:
        yaml.add_representer(OrderedDict, represent_ordereddict)

        # Make sure the output directory exists
        os.makedirs(output_dir, mode = 0o775, exist_ok = True)

        container_registry = self._application.getContainerRegistry()
        machine_manager = self._application.getMachineManager()

        machine_definition_metadata_list = container_registry.findDefinitionContainersMetadata(type = "machine")
        machine_definition_metadata_list = sorted(machine_definition_metadata_list, key = lambda x: x["id"])

        for machine_def_metadata in machine_definition_metadata_list:
            machine_def_id = machine_def_metadata["id"]
            machine_name = "{}_1".format(machine_def_metadata["name"])

            file_name = os.path.join(output_dir, "{}.yaml".format(machine_def_id))

            Logger.log("i", "Creating machine [%s] ...", machine_def_id)
            global_stack = CuraStackBuilder.createMachine(machine_name, machine_def_id)

            # Some resolve functions depends on the active machine, so this machine needs to be activated first.
            machine_manager.setActiveMachine(global_stack.getId())
            self.dumpGlobalStack(global_stack, file_name)

        Logger.log("i", "All machines processed, Exiting Cura ...")
        sys.exit(0)

    #
    # Dumps all settings of the given GlobalStack to a YAML file with the given file name.
    #
    def dumpGlobalStack(self, global_stack: "GlobalStack", file_name: str) -> None:
        machine_def_id = global_stack.definition.getId()
        machine_def_name = global_stack.definition.getName()

        machine_dict = OrderedDict({"id": machine_def_id,
                                    "name": machine_def_name,
                                    })
        machine_dict["global_settings"] = self._dumpAllSettingsFromStack(global_stack)
        machine_dict["extruder_settings"] = OrderedDict()
        extruder_position_list = sorted([int(p) for p in global_stack.extruders])
        for position in extruder_position_list:
            position = str(position)
            extruder_stack = global_stack.extruders[position]
            machine_dict["extruder_settings"][position] = self._dumpAllSettingsFromStack(extruder_stack)

        # Dump dict to file
        dir_path = os.path.dirname(file_name)
        os.makedirs(dir_path, mode = 0o775, exist_ok = True)

        with open(file_name, "w", encoding = "utf-8") as f:
            yaml.dump(machine_dict, f, default_flow_style = False)

        Logger.log("i", "Machine [%s] default settings dumped to file [%s]", machine_def_id, file_name)

    def _dumpAllSettingsFromStack(self, stack: Union["GlobalStack", "ExtruderStack"]) -> Dict[str, Dict[str, Any]]:
        all_settings_dict = dict()

        for key in stack.getAllKeys():
            value = stack.getProperty(key, "value")
            enabled = stack.getProperty(key, "enabled")

            all_values = {"value": value,
                          "enabled": enabled}
            all_settings_dict[key] = OrderedDict({k: all_values[k] for k in sorted(all_values)})

        # sort all settings by key
        all_settings_dict = OrderedDict({k: all_settings_dict[k] for k in sorted(all_settings_dict)})
        return all_settings_dict


def represent_ordereddict(dumper, data):
    return dumper.represent_dict(data.items())
