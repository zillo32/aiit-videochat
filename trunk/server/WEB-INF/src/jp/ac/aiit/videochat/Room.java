package jp.ac.aiit.videochat;

import java.util.ArrayList;
import java.util.List;

public class Room
{
    private String roomId;
    private String roomName;
    private List<Audience> audiences;
    private String roomIconUrl;
    private String roomType;  // 1--my community room  2 -- private room 3 -- open room
    
    public Room(String id, String name)
    {
        this.roomId = id;
        this.roomName = name;
    }

    public Room()
    {
        this.roomId = "0000";
        this.roomName = "";
    }

    public String getRoomId()
    {
        return roomId;
    }

    public void setRoomId(String roomId)
    {
        this.roomId = roomId;
    }

    public String getRoomName()
    {
        return roomName;
    }

    public void setRoomName(String roomName)
    {
        this.roomName = roomName;
    }

    public int getJoinedMemberCount()
    {
        return audiences == null ? 0 : audiences.size();
    }

    public List<Audience> getAudiences()
    {
        return audiences;
    }

    public void addAudience(Audience newbie)
    {
        if(this.audiences == null)
        {
            this.audiences = new ArrayList<Audience>();
        }
        this.audiences.add(newbie);
    }

    public void removeAudience(Audience newbie)
    {
        if(!this.audiences.isEmpty())
        {
            this.audiences.remove(newbie);
        }
    }
    
    public String getRoomIconUrl()
    {
		return roomIconUrl;
	}

	public void setRoomIconUrl(String roomIconUrl)
	{
		this.roomIconUrl = roomIconUrl;
	}

	public String getRoomType() {
		return roomType;
	}

	public void setRoomType(String roomType) {
		this.roomType = roomType;
	}
}