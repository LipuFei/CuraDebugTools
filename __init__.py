from .src import CuraDebugTools


def getMetaData():
    return {}


def register(app):
    return {"extension": CuraDebugTools.CuraDebugTools(app)}
