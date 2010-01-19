package jp.ac.aiit.videochat;

public class Audience
{
    private String id;
    private String color;
    private String nickName;
    private String joinedTime;
    private boolean hasCamera;
    private String userIconUrl;
    private boolean denyFlg;

    public String getId()
    {
        return id;
    }

    public void setId(String id)
    {
        this.id = id;
    }

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    public String getJoinedTime()
    {
        return joinedTime;
    }

    public void setJoinedTime(String joinedTime)
    {
        this.joinedTime = joinedTime;
    }

    public boolean isHasCamera()
    {
        return hasCamera;
    }

    public void setHasCamera(boolean hasCamera)
    {
        this.hasCamera = hasCamera;
    }

    public String getUserIconUrl()
    {
        return userIconUrl;
    }

    public void setUserIconUrl(String userIconUrl)
    {
        this.userIconUrl = userIconUrl;
    }

    public boolean isDenyFlg()
    {
        return denyFlg;
    }

    public void setDenyFlg(boolean denyFlg)
    {
        this.denyFlg = denyFlg;
    }

	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}
}