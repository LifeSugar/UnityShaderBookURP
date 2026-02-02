using UnityEngine;

public class BackgroundSwitch : MonoBehaviour
{
    private bool white = true;
    
    public void SwitchBackground()
    {
        Camera.main.backgroundColor = white ? Color.black : Color.white;
        white = !white;
    }
}
