package jp.ac.aiit.videochat;

import java.util.PropertyResourceBundle;

public class ReadProperties {
	private static final String FILENAME = "videoChat";
	public static String getPythonUrl() {
		String retUrl = "";
		try{
			PropertyResourceBundle configBundle = 
				(PropertyResourceBundle)PropertyResourceBundle.getBundle(FILENAME);
			retUrl = configBundle.getString("python.url");
		} catch(Exception ex) {
			ex.printStackTrace();
		}
		return retUrl;
	}
}
