#coding:utf8
'''
Created on 2013-10-25

@author: lan (www.9miao.com)
'''
from firefly.server.globalobject import GlobalObject,remoteserviceHandle


@remoteserviceHandle('gate')
def pushObject(topicID,msg,sendList):
    GlobalObject().netfactory.pushObject(topicID, msg, sendList)