
from typing import TYPE_CHECKING

from PyQt5.QtCore import QObject, QTimer

from UM.Extension import Extension

from .MachineSettingsDumper import MachineSettingsDumper

if TYPE_CHECKING:
    from cura.CuraApplication import CuraApplication


class CuraDebugTools(QObject, Extension):

    def __init__(self, application: "CuraApplication") -> None:
        QObject.__init__(self, parent = application)
        Extension.__init__(self)

        self._application = application

        self.setMenuName("Debug Tools")
        self.addMenuItem("Check Print Devices", self._show_print_devices)

        self._application.initializationFinished.connect(self._onApplicationInitialized)

    def _onApplicationInitialized(self) -> None:
        # schedule a task that dumps all machine default settings
        self._timer = QTimer(self)
        self._timer.setSingleShot(True)
        self._timer.timeout.connect(self._dumpAllMachineDefaultSettings)
        self._timer.start(10)

    def _dumpAllMachineDefaultSettings(self) -> None:
        dumper = MachineSettingsDumper()
        dumper.dumpAllMachinesDefaultSettings("C:/workspace/test/dump_machines")

    def _show_print_devices(self) -> None:
        machine_manager = self._application.getMachineManager()
        for device in machine_manager.printerOutputDevices:
            print("----------")
            print("    id:          %s" % device.getId())
            print("    name:        %s" % device.getName())
            print("    description: %s" % device.getDescription())
            print("    priority:    %s" % device.getPriority())

            print("    is connected: %s" % device.isConnected())
            print("    conn state:   %s" % device.connectionState)