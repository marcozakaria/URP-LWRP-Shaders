using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class SphereUIController : MonoBehaviour
{
    [SerializeField] AudioSource audioSource;

    [Header("Buttons")]
    [SerializeField] Button soundButton;
    [SerializeField] Button reloadButton;

    private bool soundDeactive = false;

    private void Start()
    {
        soundButton.onClick.AddListener(SoundButtonPressed);
        reloadButton.onClick.AddListener(ReloadButton);
    }

    public void ReloadButton()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
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
