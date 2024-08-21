import os
import sys
sys.path.append(os.path.abspath(os.getcwd()))

from runners import register as register_runners

def register(registry):
    register_runners(registry)