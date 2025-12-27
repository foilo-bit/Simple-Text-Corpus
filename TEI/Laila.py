#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import xml.etree.ElementTree as ET

# Example: Parse an XML file with UTF-8 encoding
def parse_xml_file(filepath):
    """
    Parse an XML file with explicit UTF-8 encoding.
    This avoids the 'charmap' codec error on Windows.
    """
    try:
        # ET.parse() handles UTF-8 by default, but if you get errors, use:
        # parser = ET.XMLParser(encoding='utf-8')
        # tree = ET.parse(filepath, parser=parser)
        
        tree = ET.parse(filepath)
        root = tree.getroot()
        print(f"Successfully parsed: {filepath}")
        print(f"Root element: {root.tag}")
        return root
    except UnicodeDecodeError as e:
        print(f"Unicode error: {e}")
        print("Trying with explicit UTF-8 encoding...")
        parser = ET.XMLParser(encoding='utf-8')
        tree = ET.parse(filepath, parser=parser)
        return tree.getroot()

if __name__ == "__main__":
    # Example usage:
    # root = parse_xml_file("beowulf_tei.xml")
    print("XML parser ready. Use: parse_xml_file('your_file.xml')")
