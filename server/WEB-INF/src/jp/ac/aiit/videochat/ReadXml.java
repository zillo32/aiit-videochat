package jp.ac.aiit.videochat;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class ReadXml {
	
	private static final String FILENAME = "/smile.xml";
	private List<String> outPmodeArray = new ArrayList<String>();
	private List<String> outImgArray = new ArrayList<String>();
	private List<String> outImodeArray = new ArrayList<String>();
	private List<String> outRemarkArray = new ArrayList<String>();
	private Map<String, List<String>> outMap = new HashMap<String, List<String>>();
	
	public Map<String, List<String>> getSmileArrays() {
		init();
		outMap.put("PMODE", outPmodeArray);
		outMap.put("IMG", outImgArray);
		outMap.put("IMODE", outImodeArray);
		outMap.put("REMARK", outRemarkArray);
		return outMap;
	}
	
	private void init() {
		DocumentBuilderFactory factory;
		DocumentBuilder  builder;
		Document doc;
		NodeList list;
		try {
			
			factory = DocumentBuilderFactory.newInstance();
			builder = factory.newDocumentBuilder();
			factory.setIgnoringElementContentWhitespace(true);
			factory.setIgnoringComments(true);
			factory.setValidating(true);
			doc = builder.parse(getClass().getResourceAsStream(FILENAME));
			Element element = doc.getDocumentElement();
			list = element.getChildNodes();
			
			getNodes(list);
			
		} catch (ParserConfigurationException e0) {
			System.out.println(e0.getMessage());
		} catch (SAXException e1){
			System.out.println(e1.getMessage());
		} catch (IOException e2) {
			System.out.println(e2.getMessage());
		}
	}
	
	private void getNodes(NodeList list) {
		Node node;
		for (int iNode=0; (node = list.item(iNode))!=null; iNode++) {
		    String nodeName = node.getNodeName();
		    if(nodeName.equals("smile")) {
		        // (1)要素の属性を取得
		        NamedNodeMap attrMap = node.getAttributes();
		        int attrs = attrMap.getLength();
		        for (int iAttr=0; iAttr<attrs; iAttr++) {
		            Node attr = attrMap.item(iAttr);
		            System.out.println(
		                    attr.getNodeName() + "=" + attr.getNodeValue());
		        }
		        // (2)子要素を取得
		        NodeList childNodes = node.getChildNodes();
		        Node childNode;
		        for (int iItem=0;
		                (childNode = childNodes.item(iItem))!=null; iItem++) {
		            String childName = childNode.getNodeName();
		            if (childNode.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
		                String value = null;
		                try {
		                	value = childNode.getFirstChild().getNodeValue();
		                	if(childName.equals("pmode")) {
		                		outPmodeArray.add(value);
		                	} else if(childName.equals("imode")) {
		                		outImodeArray.add(value);
		                	} else if(childName.equals("img")) {
		                		outImgArray.add(value);
		                	} else if(childName.equals("remark")) {
		                		outRemarkArray.add(value);
		                	}
		                    
		                }
		                catch (NullPointerException e) {

		                }
 		            }
		        }
		    }
		}
	}
}
