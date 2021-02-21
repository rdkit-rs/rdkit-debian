#
# Copyright (C) 2017 Peter Gedeck
#
#   @@ All Rights Reserved @@
#  This file is part of the RDKit.
#  The contents are covered by the terms of the BSD license
#  which is included in the file license.txt, found at the root
#  of the RDKit source tree.
#
'''
Collection of utilities to be used with descriptors

'''
import math

def setDescriptorVersion(version='1.0.0'):
  """ Set the version on the descriptor function.

  Use as a decorator """
  def wrapper(func):
    func.version = version
    return func
  return wrapper

<<<<<<< HEAD
class VectorDescriptorNamespace(dict):
    def __init__(self, **kwargs):
        self.update(kwargs)

=======
class VectorDescriptorNamespace:
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)
        
>>>>>>> d24111c9f5ea0c129a2416f0888f8fadb42d53c0
class VectorDescriptorWrapper:
    """Wrap a function that returns a vector and make it seem like there
    is one function for each entry.  These functions are added to the global
    namespace with the names provided"""
    def __init__(self, func, names, version, namespace):
        self.func = func
        self.names = names
        self.func_key = "__%s"%(func.__name__)
        function_namespace = {}
        for i,n in enumerate(names):
            def f(mol, index=i):
                return self.call_desc(mol, index=index)
            f.__name__ = n
            f.__qualname__ = n
            f.version = version
            function_namespace[n] = f
<<<<<<< HEAD
        self.namespace = VectorDescriptorNamespace(**function_namespace)
        self.namespace.update(namespace)
=======
        self.namespace = VectorDescriptorNamespace(**function_namespace)            
>>>>>>> d24111c9f5ea0c129a2416f0888f8fadb42d53c0
        namespace.update(function_namespace)

    def _get_key(self, index):
        return "%s%s"%(self.func_key, index)
<<<<<<< HEAD

=======
    
>>>>>>> d24111c9f5ea0c129a2416f0888f8fadb42d53c0
    def call_desc(self, mol, index):
        if hasattr(mol, self.func_key):
          results = getattr(mol, self.func_key, None)
          if results is not None:
            return results[index]
<<<<<<< HEAD

=======
        
>>>>>>> d24111c9f5ea0c129a2416f0888f8fadb42d53c0
        try:
          results = self.func(mol)
        except:
          return math.nan

        setattr(mol, self.func_key, results)
        return results[index]

