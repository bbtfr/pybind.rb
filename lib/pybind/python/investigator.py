from distutils.sysconfig import get_config_var
import sys

print('EXECUTABLE: ' + str(sys.executable))
print('EXECPREFIX: ' + str(sys.exec_prefix))
print('PREFIX: ' + str(sys.prefix))
if sys.version_info >= (3, 3):
    print('IMPLEMENTATIONMULTIARCH: ' + str(sys.implementation._multiarch))
for var in ('VERSION', 'INSTSONAME', 'LIBRARY', 'LDLIBRARY', 'LIBDIR', 'PYTHONFRAMEWORKPREFIX', 'MULTIARCH'):
  print(var + ': ' + str(get_config_var(var)))
