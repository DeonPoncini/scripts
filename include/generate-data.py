#!/usr/bin/python

################################################################################
# generate-data
# reads a data XML file and generates headers in various languages
################################################################################

import codecs
import os.path
import sys

from xml.dom import minidom

# typemaps
c_data_types = { \
        'string':'char*', \
        'unsigned':'unsigned', \
        'int':'int', \
}

cpp_data_types = { \
        'string':'std::string', \
        'unsigned':'unsigned', \
        'int':'int', \
}

java_data_types = { \
        'string':'String', \
        'unsigned':'int', \
        'int':'int', \
}

# data structures
class Package:
    def __init__(self, uri, ns):
        self.uri = uri
        self.ns = ns

class Enumeration:
    def __init__(self, name, entries):
        self.name = name
        self.entries = entries

class Constant:
    def __init__(self, name, dataType, value):
        self.name = name
        self.dataType = dataType
        self.value = value

class Structure:
    def __init__(self, name, elements):
        self.name = name
        self.elements = elements

def write_cpp(packageObjs, enumObjs, constantObjs, structObjs, \
        outPath, fileName):
    outfile = codecs.open(os.path.join(outPath, 'cpp', fileName + '.h'),
            'w', 'utf-8')
    guard=""
    for n in packageObj.ns:
        guard = guard + n.upper() + '_'
    guard += fileName.upper() + '_H_CPP'
    outfile.write('#ifndef ' + guard + '\n')
    outfile.write('#define ' + guard + '\n')
    outfile.write('#include <string>\n')
    for n in packageObj.ns:
        outfile.write('namespace ' + n + ' {\n')

    # enumerations
    for e in enumObjs:
        outfile.write('enum class ' + e.name + ' {\n')
        for entry in e.entries:
            outfile.write('\t' + entry + ',\n')
        outfile.write('};\n')

    # constants
    for c in constantObjs:
        outfile.write('static const ' + cpp_data_types[c.dataType] + ' ' \
                + c.name + ' = ' + c.value + ';\n')

    # structs
    for s in structObjs:
        outfile.write('struct ' + s.name + ' {\n')
        for e in s.elements:
            if e.dataType in cpp_data_types:
                outfile.write('\t' + cpp_data_types[e.dataType] + ' ' \
                        + e.name + ';\n')
            else:
                outfile.write('\t' + e.dataType + ' ' + e.name + ';\n')
        outfile.write('};\n')

    for n in packageObj.ns:
        outfile.write('}\n')

    outfile.write('#endif\n')

def write_c(packageObjs, enumObjs, constantObjs, structObjs, outPath, fileName):
    outfile = codecs.open(os.path.join(outPath, 'c', fileName + '.h'),
            'w', 'utf-8')
    guard=""
    for n in packageObj.ns:
        guard = guard + n.upper() + '_'
    guard += fileName.upper() + '_H_C'
    outfile.write('#ifndef ' + guard + '\n')
    outfile.write('#define ' + guard + '\n')
    outfile.write('#ifdef __cplusplus\n')
    outfile.write('extern "C" {\n')
    outfile.write('#endif\n')
    nsprefix = ""
    for n in packageObj.ns:
        nsprefix = nsprefix + n + '_'

    # enumerations
    for e in enumObjs:
        outfile.write('enum ' + nsprefix + e.name + ' {\n')
        for entry in e.entries:
            outfile.write('\t' + nsprefix + e.name + '_' + entry + ',\n')
        outfile.write('};\n')

    # constants
    for c in constantObjs:
        outfile.write('static const ' + c_data_types[c.dataType] + ' ' \
                + nsprefix + c.name + ' = ' + c.value + ';\n')

    # structs
    for s in structObjs:
        outfile.write('struct ' + nsprefix + s.name + ' {\n')
        for e in s.elements:
            if e.dataType in c_data_types:
                outfile.write('\t' + c_data_types[e.dataType] + ' ' \
                        + e.name + ';\n')
            else:
                outfile.write('\t' + nsprefix + e.dataType + ' ' + e.name + ';\n')
        outfile.write('};\n')

    outfile.write('#ifdef __cplusplus\n')
    outfile.write('}\n')
    outfile.write('#endif\n')
    outfile.write('#endif\n')

def write_java(packageObjs, enumObjs, constantObjs, structObjs, \
        outPath, fileName):
    paths = packageObjs.uri.split(".")
    paths.reverse()
    for n in packageObj.ns:
        paths.append(n)

    fullPath = os.path.join(outPath,'java', *paths)
    if not os.path.exists(fullPath):
        os.makedirs(fullPath)
    outfile = codecs.open(os.path.join(fullPath, fileName + '.java'), 'w', 'utf-8')

    packageName = ''
    for p in paths:
        packageName = packageName + p + '.'
    packageName = packageName[:-1]
    outfile.write('package ' + packageName + ';\n')

    # outer class
    outfile.write('public class ' + fileName + ' {\n')

    # enumerations
    for e in enumObjs:
        outfile.write('public enum ' + e.name + ' {\n')
        for entry in e.entries:
            outfile.write('\t' + entry + ',\n')
        outfile.write('}\n')

    # constants
    for c in constantObjs:
        outfile.write('public static final ' + java_data_types[c.dataType] + \
                ' ' + c.name + ' = ' + c.value + ';\n')

    # structs
    for s in structObjs:
        outfile.write('public static class ' + s.name + '{\n')
        for e in s.elements:
            if e.dataType in java_data_types:
                outfile.write('\tpublic ' + java_data_types[e.dataType] + ' ' \
                        + e.name + ';\n')
            else:
                outfile.write('\tpublic ' + e.dataType + ' ' + e.name + ';\n')
        outfile.write('}\n')

    # close class
    outfile.write('}\n')

if len(sys.argv) < 3:
    print "Usage is: " + sys.argv[0] + " <data.xml> <outpath> "
    sys.exit(1)

dataDom = minidom.parse(sys.argv[1])
outPath = sys.argv[2]

# get the output file name
datas = dataDom.getElementsByTagName('data')
if len(datas) > 1:
    print "Only one data element allowed"
    sys.exit(1)

fileName = datas[0].getAttribute('name')

# get the package declaration
packages = dataDom.getElementsByTagName('package')

if len(packages) > 1:
    print "Only one package element allowed"
    sys.exit(1)

uri = packages[0].getAttribute('uri')
namespace = packages[0].getElementsByTagName('namespace')
nslist = []
for n in namespace:
    nslist.append(n.childNodes[0].nodeValue)
packageObj = Package(uri, nslist)

# parse all the enums
enumObjs = []
enums = dataDom.getElementsByTagName('enum')
for e in enums:
    name = e.getAttribute('name')
    entries = e.getElementsByTagName('entry')
    entryList = []
    for e1 in entries:
        entryList.append(e1.childNodes[0].nodeValue)
    enumObjs.append(Enumeration(name,entryList))

# parse all the constants
constantObjs = []
constants = dataDom.getElementsByTagName('constant')
for c in constants:
    name = c.getAttribute('name')
    dataType = c.getAttribute('type')
    value = c.childNodes[0].nodeValue
    constantObjs.append(Constant(name, dataType, value))

# parse all the structs
structObjs = []
structs = dataDom.getElementsByTagName('struct')
for s in structs:
    sname = s.getAttribute('name')
    elements = s.getElementsByTagName('element')
    elementList = []
    for e in elements:
        name = e.childNodes[0].nodeValue
        dataType = e.getAttribute('type')
        elementList.append(Constant(name, dataType, 0))
    structObjs.append(Structure(sname, elementList))

write_cpp(packageObj, enumObjs, constantObjs, structObjs, outPath, fileName)
write_c(packageObj, enumObjs, constantObjs, structObjs, outPath, fileName)
write_java(packageObj, enumObjs, constantObjs, structObjs, outPath, fileName)