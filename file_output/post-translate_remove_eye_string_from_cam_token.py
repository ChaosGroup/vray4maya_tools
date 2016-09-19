'''
When rendering with a stereoscopic camera with V-Ray for Maya, V-Ray will always append
the name of the camera "eye" to output file name when a <camera> token is used in the
output file name. This script edits the scene after the camera token has been expanded.

NOTE: this will replace ALL occurences of the <camera> token in the output filename, in case the
token is used more than once.

NOTE: The intended use of this is to remove the camera "eye" string from the output filename.

Usage: Copy the script as a post-translate python script in the Common tab of the Render Settings.
'''


import maya.mel as mel
import maya.cmds as cmds
from vray.utils import *

# variables
toFind = ""
toRemove = ""
fPrefix = ""

# find the SettingsOutput plugin
so = findByType('SettingsOutput')[0]

# get the img_file parameter
getImg = so.get('img_file')

# get the current camera
cCam = mel.eval('vrend -query -camera')
cCamShape = cmds.listRelatives(cCam, shapes=True)[0]

# get the current stereo eye
# 0=Left_AND_Right, 1=Left, 2=Right, 3=Center
# first check if the attribute exists and if stereo is enabled
if cmds.attributeQuery('vrayCameraStereoscopicOn', node=cCamShape, exists=True)==1 and cmds.getAttr(cCamShape + '.vrayCameraStereoscopicOn')==1:
    cEye = cmds.getAttr(cCamShape + '.vrayCameraStereoscopicView')

    if cEye == 0:
        toFind = "_Left_AND_Right"
    elif cEye == 1:
        toFind = "_Left"
    elif cEye == 2:
        toFind = "_Right"
    elif cEye == 3:
        toFind = "_Center"

    # remove the eye string from the camera token
    toRemove = getImg.replace(toFind, "")
    
    # set the image file name
    so.set('img_file', toRemove)