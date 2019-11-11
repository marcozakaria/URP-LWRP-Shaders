using UnityEngine;
using UnityEngine.UI;

public class SphereUIController : MonoBehaviour
{
    [SerializeField] AudioSource audioSource;

    [Header("Buttons")]
    [SerializeField] Button soundButton;
    private bool soundDeactive = false;

    private void Start()
    {
        soundButton.onClick.AddListener(SoundButtonPressed);
    }

    public void SoundButtonPressed()
    {
        if (soundDeactive)
        {
            audioSource.Pause();
            soundDeactive = false;
        }
        else
        {
            audioSource.UnPause();
            soundDeactive = true;
        }
    }
}
