import zipfile
import xml.etree.ElementTree as ET

def read_docx(file_path):
    try:
        with zipfile.ZipFile(file_path) as docx:
            xml_content = docx.read('word/document.xml')
            tree = ET.XML(xml_content)
            
            # The namespace for Word XML
            WORD_NAMESPACE = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
            PARA = WORD_NAMESPACE + 'p'
            TEXT = WORD_NAMESPACE + 't'
            
            texts = []
            for paragraph in tree.iter(PARA):
                para_texts = [node.text for node in paragraph.iter(TEXT) if node.text]
                if para_texts:
                    texts.append(''.join(para_texts))
            return '\n'.join(texts)
    except Exception as e:
        return str(e)

text = read_docx(r"c:\xampp\htdocs\SILATORJANA\Laporan Proyek Si-LATORJANA.docx")
with open("laporan_extracted.txt", "w", encoding="utf-8") as f:
    f.write(text)
