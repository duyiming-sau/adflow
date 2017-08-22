#!/usr/bin/python
from __future__ import print_function
from __future__ import division

"""zipperChecker: A small utility to check zipper zipper meshes
generated by ADFlow.
"""

# =============================================================================
# Imports
# =============================================================================

import os
import sys
from . import MExt


def checkZipper(fileName):
    """Run the zipper code on the supplied zipper debug file"""

    # Import the adflow module, we won't be useing much of it
    curDir = os.path.dirname(os.path.realpath(__file__))
    adflow = MExt.MExt('libadflow', [curDir], debug=True)._module
    adflow.zippermesh.checkzipper(fileName)
