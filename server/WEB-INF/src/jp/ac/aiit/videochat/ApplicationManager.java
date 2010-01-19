package jp.ac.aiit.videochat;

import static jp.ac.aiit.videochat.ApplicationConstants.ATT_CONNECTION_ME;
import static jp.ac.aiit.videochat.ApplicationConstants.DEFAULT_FORMAT;
import static jp.ac.aiit.videochat.ApplicationConstants.SCOPE_HALL;
import static org.red5.server.api.service.ServiceUtils.invokeOnAllConnections;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.PostMethod;
import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IClient;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.Red5;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ApplicationManager extends ApplicationAdapter {

	/**
	 * Logger object
	 */
	private static final Logger log = LoggerFactory.getLogger( ApplicationManager.class );
	

	/**
	 * Room object list
	 */
	private Map<String, Room> rooms = new HashMap<String, Room>();
	

	/**
	 * User object list
	 */
//	private Map<String, List<Map<String, Object>>> userVideos = new HashMap<String, List<Map<String, Object>>>();
	
	
	//１個以上の部屋へ参加するのチェック
//	private Map<String, String>usersInfo = new HashMap<String, String>();
	// 同じユーザ、ダブル部屋に参加情報
	private Map<String, ArrayList<String>> userRoomsInfo = new HashMap<String, ArrayList<String>>(); 
		
	// 登録したユーザ一覧
	private Map<String, Integer > usersName = new HashMap<String, Integer>();

	// 入室・退室の状態
	private String status = "";
	// オープン部屋
	private static final List<String> openroomList = Arrays.asList("o999999990", "o999999991", "o999999992", "o999999993"); 
	/**
	 * デバッグモード設定
	 */
	private boolean _isDebugMode() {
		return true;
//		return false;
	}

	/**
	 * 
	 */
	@Override
	public synchronized boolean roomStart(IScope room) {
		
		if ( _isDebugMode() ){
			log.info("#roomStart(S): room => {}", new Object[] { room } );
		}
		
		if (!super.roomStart(room)) {
			return false;
		}
		
		// 通常の部屋（ホール以外）の場合に部屋オブジェクトを生成する
		if (room.getName().compareTo(SCOPE_HALL) != 0) {
			Room r = new Room();
			r.setRoomId(room.getName());
			if(!rooms.containsKey(r.getRoomId())) {
				if(usersName.containsKey(r.getRoomId())) {
					r.setRoomType("2");
				} else if(openroomList.contains(r.getRoomId())) {
					log.debug("TEST OPEN ROOM TYPE");
					r.setRoomType("3");
				} else {
					r.setRoomType("1");
				}
				rooms.put(r.getRoomId(), r);
			} else {
				r = rooms.get(r.getRoomId());
			}

			invokeOnAllConnections(getChildScope(SCOPE_HALL),
					"hallOnRoomCreated", new Object[] { r });
		}
		
		if ( _isDebugMode() ){
			log.info("#roomStart(E).");
		}
		
		return true;
	}

	
	/**
	 * 
	 */
	@Override
	public synchronized void roomStop(IScope room) {
		if ( _isDebugMode() ){
			log.info("#roomStop(S): room => {}", new Object[] { room });
		}
		
		super.roomStop(room);
		if (room.getName().compareTo(SCOPE_HALL) != 0) {
			invokeOnAllConnections(getChildScope(room.getName()),
					"hallOnRoomDestoryed", new Object[] { room.getName() });
//			rooms.remove(room.getName());
		}
		
		if ( _isDebugMode() ){
			log.info("#roomStop(E).");
		}
		
	}

	
	/**
	 * 
	 */
	@Override
	public synchronized boolean roomConnect(IConnection conn, Object[] params) {
		if (_isDebugMode()) {
			log.info("#roomConnect(S): conn => {}, params => {}", new Object[] { conn, params });
		}
		
		if (!super.roomConnect(conn, params)) {
			return false;
		}
		IScope scope = conn.getScope();
		if (scope.getName().compareTo(SCOPE_HALL) == 0) {
			if (params != null) {
				Audience audience = new Audience();
				audience.setId(params[2].toString());
				audience.setNickName(params[0].toString());
				audience.setHasCamera(false);
				audience.setDenyFlg(false);
				audience.setUserIconUrl(params[1].toString());
				// 登録したユーザを保存
				// ユーザの登録回数
				int count = 1;
				if(usersName.containsKey(audience.getId())) {
					 count = usersName.get(audience.getId()).intValue() + 1;
				}
				usersName.put(audience.getId(), (Integer) count);
				conn.setAttribute(ATT_CONNECTION_ME, audience);
			}
		}
		
		if (_isDebugMode()) {
			log.info("#roomConnect(E).");
		}

		return true;
	}

	
	/**
	 * 
	 */
	@Override
	public synchronized boolean roomJoin(IClient client, IScope room) {
		if ( _isDebugMode() ){
			log.info("#roomJoin(S): client => {}, room => {}", new Object[] { client, room });
		}

		if (!super.roomJoin(client, room)) {
			return false;
		}
		Audience me = (Audience) Red5.getConnectionLocal().getAttribute(
				ATT_CONNECTION_ME);

		if (room.getName().compareTo(SCOPE_HALL) == 0) {
			invokeOnAllConnections(room, "hallOnJoin", new Object[] { me });
		} else {
			status = "join";
			Room theRoom = rooms.get(room.getName());
			//ユーザーと部屋情報更新
			updateUserRoom(room.getName(), me);
			
			updateUserRoomsInfo(me.getNickName(), theRoom.getRoomId(), "1");
			
			invokeOnAllConnections(room, "roomOnJoin", new Object[] { theRoom,
					me });
			invokeOnAllConnections(getChildScope(SCOPE_HALL),
					"hallOnRoomUpdated", new Object[] { theRoom,  status});
		}

		if ( _isDebugMode() ){
			log.info("#roomJoin(E).");
		}

		return true;
	}

	/**
	 * 
	 */
	@Override
	public synchronized void roomLeave(IClient client, IScope room) {
		if ( _isDebugMode() ){
			log.info("#roomLeave(S): client => {}, room => {}", new Object[] { client, room });
		}

		super.roomLeave(client, room);

		Audience me = (Audience) Red5.getConnectionLocal().getAttribute(
				ATT_CONNECTION_ME);

		
		// 20091017 参加者が減った部屋の一覧用Map ===>
		Map<String, Room> memberLeftRooms = new HashMap<String, Room>();
		// <===
		

		// 個人部屋の消す
		if (room.getName().compareTo(SCOPE_HALL) == 0) {
			// 登録しないユーザを削除  または　ユーザの登録回数減らす
			reduceUsersId(me.getId());
			
			invokeOnAllConnections(room, "hallOnLeave", new Object[] { me });
			if(!usersName.containsKey(me.getId())) {
				if(rooms.containsKey(me.getId())) {
					Room theRoom = rooms.get(me.getId());
					if(theRoom.getJoinedMemberCount() == 0) {
						rooms.remove(theRoom.getRoomId());
						// 20091017 参加者が減った部屋だけクライアントへ返却する ===>
						memberLeftRooms.put(theRoom.getRoomId(), theRoom );
						// <===
					}
				}
			}
			if ( _isDebugMode() ){
				log.info("#roomLeave(before call delRoomsList): memberLeftRooms.size() => {}", new Object[] { memberLeftRooms.size() });
			}

			invokeOnAllConnections(getChildScope(SCOPE_HALL), "delRoomsList", new Object[]{memberLeftRooms});
			
		} else {

			status = "leave";
			Room theRoom = rooms.get(room.getName());
			theRoom.removeAudience(me);
			//個人部屋の消す
			//windowの閉じるボタンを押すなど
			if(!me.getJoinedTime().equals("9999")) {
				reduceUsersId(me.getId());
			}
			if(theRoom.getRoomType().equals("2")) {
				if((!usersName.containsKey(theRoom.getRoomId()))
						&& theRoom.getJoinedMemberCount() == 0) {
					rooms.remove(theRoom.getRoomId());
					// 20091017 参加者が減った部屋だけクライアントへ返却する ===>
					memberLeftRooms.put(theRoom.getRoomId(), theRoom );
					// <===
					if ( _isDebugMode() ){
						log.info("#roomLeave(before call delRoomsList): memberLeftRooms.size() => {}", new Object[] { memberLeftRooms.size() });
					}
					invokeOnAllConnections(getChildScope(SCOPE_HALL), "delRoomsList", new Object[]{memberLeftRooms});
				}
			}

			//ユーザMAP更新
			updateUserRoomsInfo(me.getNickName(), theRoom.getRoomId(), "2");
			invokeOnAllConnections(getChildScope(SCOPE_HALL), "roomOnLeave",
					new Object[] { theRoom, me });
			invokeOnAllConnections(getChildScope(SCOPE_HALL),
					"hallOnRoomUpdated", new Object[] { theRoom,  status});


		}
		
		if ( _isDebugMode() ){
			log.info("#roomLeave(E).");
		}		
	}

	
	/**
	 * 
	 * 登録しないのユーザ削除　または　ユーザの登録回数減らす
	 */
	private synchronized void reduceUsersId(String userId) {

		if ( _isDebugMode() ){
			log.info("#reduceUsersId(S): userId => {}", userId );
		}
		
		if(usersName.containsKey(userId)) {
			int count = usersName.get(userId).intValue() - 1;
			if(count == 0) {
				usersName.remove(userId);
			} else {
				usersName.put(userId, (Integer) count);
			}
		}

		if ( _isDebugMode() ){
			log.info("#reduceUsersId(E).");
		}
	}
	

	/**
	 * 
	 * @param roomName
	 * @param audience
	 */
	private synchronized void updateUserRoom(String roomName, Audience audience) {

		if ( _isDebugMode() ){
			log.info("#updateUserRoom(S): roomName => {}, audience => {}", new Object[] { roomName, audience } );
		}
		//監視者の場合
		if(audience.getNickName().indexOf("debug") >= 0) {
			return;
		}
		Room theRoom = rooms.get(roomName);
		ArrayList<String> roomList = new ArrayList<String>();
		if(userRoomsInfo.containsKey(audience)) {
			roomList = userRoomsInfo.get(audience);
			if(!roomList.contains(theRoom.getRoomId())) {
				theRoom.addAudience(audience);
			}
		} else {
			theRoom.addAudience(audience);
		}

		if ( _isDebugMode() ){
			log.info("#updateUserRoom(E).");
		}
	}
	
	/**
	 * 
	 * @param userName
	 * @param roomId
	 * @return
	 */
	public synchronized boolean leavePreRoom(String userName, String roomId) {

		if ( _isDebugMode() ){
			log.info("#leavePreRoom(S): userName => {}, roomId => {}", new Object[] { userName, roomId });
		}
		
		invokeOnAllConnections(getChildScope(SCOPE_HALL), "previousRoomOnLeave", new Object[]{userName, roomId});

		if ( _isDebugMode() ){
			log.info("#leavePreRoom(E).");
		}
		
		return true;
	}
	
	/**
	 * 
	 * @param userName
	 * @return
	 */
	public synchronized boolean walkinNextRoom(String userName) {

		if ( _isDebugMode() ){
			log.info("#walkinNextRoom(S): userName => {}", new Object[]{userName} );
		}
		
		invokeOnAllConnections(getChildScope(SCOPE_HALL), "nextRoomOnJoin", new Object[]{userName});

		if ( _isDebugMode() ){
			log.info("#walkinNextRoom(E).");
		}
		
		return true;

	}
	
	/**
	 * 
	 * @param roomName
	 * @return
	 */
	public synchronized boolean createAndJoinRoom(String roomName) {

		if ( _isDebugMode() ){
			log.info("#createAndJoinRoom(S): roomName => {}", new Object[] { roomName } );
		}
		
		IScope scope = getChildScope(roomName);
		if (scope == null) {
			if (!createRoom(roomName)) {
				return false;
			}
		}

		if ( _isDebugMode() ){
			log.info("#createAndJoinRoom(E).");
		}
		
		return _joinRoom(roomName);
	}
	
	/**
	 * 
	 * @param userName
	 * @param roomName
	 * @param actionFlg
	 */
	private synchronized void updateUserRoomsInfo(String userName, String roomName, String actionFlg) {

		if ( _isDebugMode() ){
			log.info("#updateUserRoomsInfo(S): userName => {}, roomName => {}, actionFlg => {}", new Object[] { userName, roomName, actionFlg } );
		}
				
		//監視者の場合
		if(userName.indexOf("debug") >= 0) {
			return;
		}
		
		ArrayList<String> roomList = new ArrayList<String>();
		// 部屋追加
		if (actionFlg.equals("1")) {
			if (!userRoomsInfo.containsKey(userName)) {
				roomList.add(roomName);
			} else {
				roomList = userRoomsInfo.get(userName);
				if (!roomList.contains(roomName)) {
					roomList.add(roomName);
				}
			}
		// 部屋削除
		} else if(actionFlg.equals("2")) {
			roomList = userRoomsInfo.get(userName);
			roomList.remove(roomName);
			
		}
		userRoomsInfo.put(userName, roomList);

		if ( _isDebugMode() ){
			log.info("#updateUserRoomsInfo(E).");
		}

	}
	
	/**
	 * 
	 * @param userName
	 * @param roomName
	 * @return
	 */
	public synchronized String checkUserRoomsInfo(String userName, String roomName) {

		if ( _isDebugMode() ){
			log.info("#checkUserRoomsInfo(S): userName => {}, roomName => {}", new Object[] { userName, roomName } );
		}

		String result = "0";
		if (userRoomsInfo.containsKey(userName)) {
			ArrayList<String> roomList = userRoomsInfo.get(userName);
			if (roomList.contains(roomName)) {
				result = "1"; // 同じ部屋に既に入室しました。
			} else {
				result = "2"; // ほかの部屋に入室しました。
			}
		}

		if ( _isDebugMode() ){
			log.info("#checkUserRoomsInfo(E): result => {}.", result);
		}
		
		return result; // 初めで部屋に入室する。
	}
	
	/**
	 * 
	 * @param roomName
	 * @return
	 */
	public synchronized boolean createRoom(String roomName) {

		if ( _isDebugMode() ){
			log.info("#createRoom(): roomName => {}", new Object[] { roomName } );
		}

		//		return !rooms.containsKey(roomName) && createChildScope(roomName);
		return createChildScope(roomName);
	}

	/**
	 * initCreateRooms(ArrayList<Object>)
	 * 
	 * このメソッドはクライアントから呼び出される（HallService）
	 * 
	 * @param lrooms
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public synchronized boolean initCreateRooms(ArrayList<Object> lrooms) {

		if ( _isDebugMode() ){
			log.info("#initCreateRooms(S): lrooms.size() => {}", new Object[] { lrooms.size() } );
		}
		
		// 20091017 参加者がいる部屋の一覧用Map ===>
		Map<String, Room> memberJoinedRooms = new HashMap<String, Room>();
		// <===
		
		for(int i = 0; i < lrooms.size(); i++) {
			HashMap<String, String> lrMap = (HashMap<String, String>)lrooms.get(i);
			if(!rooms.containsKey(lrMap.get("roomId"))) {
				Room r = new Room();
				r.setRoomId(lrMap.get("roomId"));
				r.setRoomName(lrMap.get("roomName"));
				r.setRoomIconUrl(lrMap.get("roomIconUrl"));
				r.setRoomType(lrMap.get("roomType"));
				rooms.put(r.getRoomId(), r);
			}
			
			// 20091017 参加者がいる部屋とマイミク部屋だけクライアントへ返却する ===>
			Room tmpRoom = rooms.get(lrMap.get("roomId"));
			
			if ( 0 < tmpRoom.getJoinedMemberCount() || tmpRoom.getRoomType().equals("2") ) {
				memberJoinedRooms.put(tmpRoom.getRoomId(), tmpRoom );
			}
			// <===
			
		}
		
		Collection<Room> rs = rooms.values();
		for (Iterator<Room> it = rs.iterator(); it.hasNext(); ){
			Room r = it.next();
			if ( 0 < r.getJoinedMemberCount() || r.getRoomType().equals("2") ){
				memberJoinedRooms.put(r.getRoomId(), r);
			}
		}
		
		if ( _isDebugMode() ){
			log.info("#initCreateRooms(before invoke): memberJoinedRooms.size() => {}",new Object[] { memberJoinedRooms.size() } );
		}
		
		
		invokeOnAllConnections(getChildScope(SCOPE_HALL), "refreshRoomsList", new Object[]{memberJoinedRooms});


		if ( _isDebugMode() ){
			log.info("#initCreateRooms(): rooms.size() => {}", new Object[] { rooms.size() } );
			log.info("#initCreateRooms(E).");
		}
		
		return true;
	}
	
	/**
	 * _joinRoom(String)
	 * 
	 * @param roomId
	 * @return
	 */
	private synchronized boolean _joinRoom(String roomId) {
		IScope roomScope = getChildScope(roomId);
		IConnection conn = Red5.getConnectionLocal();
		return conn.connect(roomScope);
	}

	/**
	 * leaveRoom(String)
	 * 
	 * このメソッドはクライアントから呼び出される（RoomService）
	 * 
	 * @param roomName
	 * @return
	 */
	public synchronized boolean leaveRoom(String roomName) {

		if ( _isDebugMode() ){
			log.info("#leaveRoom(S): roomName => {}", new Object[] { roomName } );
		}

		
		// 「退室」ボタンを押した　joinedTime = "9999"
		Audience me = (Audience) Red5.getConnectionLocal().getAttribute(
				ATT_CONNECTION_ME);
		me.setJoinedTime("9999"); // 該当ユーザが無効にさせる
		IScope roomScope = getChildScope(roomName);
		IConnection conn = Red5.getConnectionLocal();
		roomScope.disconnect(conn);
		IScope hallScope = getChildScope(SCOPE_HALL);

		conn.connect(hallScope);

		if ( _isDebugMode() ){
			log.info("#leaveRoom(E).");
		}
		
		return true;
	}

	/**
	 * sendPublicMessage(String, String) 
	 * 
	 * このメソッドはクライアントから呼び出される（RoomService）
	 * 
	 * @param msg
	 * @param color
	 * @return
	 */
	public boolean sendPublicMessage(String msg, String color) {


		IConnection conn = Red5.getConnectionLocal();
		Audience me = (Audience) conn.getAttribute(ATT_CONNECTION_ME);
		String roomID = conn.getScope().getName();
		// room
		Room r = rooms.get(roomID);



		try {
// ↓↓↓↓↓ 11.02 HttpClient3.1 への変更
			String strUrl = ReadProperties.getPythonUrl();
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(strUrl);
			
			method.addParameter("msg", msg);
			method.addParameter("room", r.getRoomName());
			method.addParameter("room_id", roomID);
			method.addParameter("me", me.getNickName());
			method.addParameter("me_id", me.getId());
			method.addParameter("roomType", r.getRoomType());
			
			method.getParams().setContentCharset("UTF-8");
			client.executeMethod(method);
			
			BufferedReader bis = new BufferedReader(new InputStreamReader(
										method.getResponseBodyAsStream()));
// ↑↑↑↑↑ 11.02 HttpClient への変更	

	
/*			URL url = new URL(ReadProperties.getPythonUrl());
			HttpURLConnection http = (HttpURLConnection) url.openConnection();
			http.setRequestMethod("POST");
			http.setDoOutput(true);
			OutputStreamWriter osw = new OutputStreamWriter(http
					.getOutputStream());

			if ( _isDebugMode() ){
				log.info( "#sendPublicMessage(): room => {}, who => {}, msg => {}, color => {}", new Object[] { r.getRoomName(), me.getNickName(), msg, color } );
			}
			
//↓↓↓↓↓ 10.05 googlecus への出力変更 by zhg
			String strMsgToGooglecus = 
				"msg=" + URLEncoder.encode(msg, "UTF-8") 
				+ "&room=" + r.getRoomName() + "&room_id=" + roomID
				+ "&me=" + me.getNickName() + "&me_id=" + me.getId()
				+ "&roomType" + r.getRoomType();
			osw.write( strMsgToGooglecus );
			
//			osw.write("msg=" + msg + "&room=" + roomName + "&me="
//					+ me.getNickName() + "&roomType" + r.getRoomType());
//↑↑↑↑↑ 10.05 googlecus への出力変更 by zhg
			osw.flush();
			osw.close();

			BufferedReader bis = new BufferedReader(new InputStreamReader(http
					.getInputStream()));
*/
			String str;
			while ((str = bis.readLine()) != null) {
				invokeOnAllConnections(conn.getScope(),
						"roomReceivePublicMessage", new Object[] {
								rooms.get(roomID), me, _decorateMsg(str, color) });
			}
			bis.close();
			method.releaseConnection();
			
//			http.disconnect();
			
		} catch (Exception e) {
			// e.printStackTrace();
		}

		return true;
	}

	/**
	 * _decorateMsg(String, String)
	 * 
	 * @param msg
	 * @param color
	 * @return
	 */
	private synchronized String _decorateMsg(String msg, String color) {
	    return "<FONT COLOR=\"" + color +  "\">" + msg + "</FONT>";
	}


	/**
	 * getRooms()
	 * 
	 * このメソッドはクライアントから呼び出される（HallService）
	 * 
	 * @return
	 */
	public synchronized Collection<Room> getRooms() {

		if ( _isDebugMode() ){
			log.info("#getRooms(S): rooms.size() => {} ", new Object[] {rooms.size()} );
		}
		
		Collection<Room> result = new ArrayList<Room>();
		Collection<Room> rs = rooms.values();
		for (Iterator<Room> it = rs.iterator(); it.hasNext(); ){
			Room r = it.next();
			if ( 0 < r.getJoinedMemberCount() || r.getRoomType().equals("2") ){
				result.add( r );
			}
		}

		if ( _isDebugMode() ){
			log.info("#getRooms(E): result.size() => {} ", new Object[] {result.size()} );
		}
		
		return result;
	}

	/**
	 * getAudiences(roomName:String)
	 * 
	 * このメソッドはクライアントから呼び出される（HallService, RoomService）
	 * 
	 * @param roomName
	 * @return
	 */
	public synchronized Collection<Audience> getAudiences(String roomName) {

		if ( _isDebugMode() ){
			log.info("#getAudiences(S): roomName => {}", new Object[] { roomName } );
		}


		Collection<Audience> tmpAudiences = new ArrayList<Audience>();
		if (rooms.get(roomName) != null) {
			tmpAudiences = rooms.get(roomName).getAudiences();
		}

		if ( _isDebugMode() ){
			log.info("#getAudiences(E).");
		}

		return tmpAudiences;
	}


	/**
	 * getUsersVideo( String ):Collection
	 * 
	 * 未使用のメソッド
	 * 
	 * @param roomName
	 * @return
	 */
//	public Collection<Map<String, Object>> getUsersVideo(String roomName) {
//		return userVideos.get(roomName);
//	}

	/**
	 * publishCamera(boolean, boolean, String, String):boolean
	 * 
	 * このメソッドはクライアントから呼び出される（RoomService）
	 * 
	 * @param hasCamera
	 * @param denyFlg
	 * @param roomId
	 * @param userName
	 * @return
	 */
	public synchronized boolean publishCamera(boolean hasCamera, boolean denyFlg, String roomId, String userName) {

		if ( _isDebugMode() ){
			log.info("#publishCamera(S): hasCamera => {}, debyFlg => {}, roomId => {}, userName => {}", new Object[] { hasCamera, denyFlg, roomId, userName } );
		}

		IConnection conn = Red5.getConnectionLocal();
		Audience currentUser = null;

		for (Audience user : rooms.get(roomId).getAudiences()) {
			if (user.getNickName().equals(userName)) {
				user.setDenyFlg(denyFlg);
				user.setHasCamera(hasCamera);
				user.setJoinedTime(_now());
				currentUser = user;
				break;
			}
		}
		invokeOnAllConnections(conn.getScope(), "updateMemberlist",
				new Object[] { currentUser });

		if ( _isDebugMode() ){
			log.info("#publishCamera(E).");
		}
		
		return true;
	}

	/**
	 * now():String
	 * 
	 * @return
	 */
	private String _now() {
		return new SimpleDateFormat(DEFAULT_FORMAT).format(Calendar
				.getInstance().getTime());
	}

	/**
	 * get_all_contents(String):Map
	 * 
	 * このメソッドはクライアントから呼び出される（RoomService）
	 * 
	 * @param args
	 * @return
	 */
	public synchronized Map<String, List<String>> get_all_contents(String args) {
		
		return new ReadXml().getSmileArrays();
	}
	
	
}