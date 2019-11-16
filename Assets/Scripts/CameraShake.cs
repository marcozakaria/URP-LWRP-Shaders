using UnityEngine;

public class CameraShake : MonoBehaviour
{
    public static CameraShake instance = null;

    [Header("positional Shake")]
    [SerializeField] float shakeTime = 0.5f; //0.1
    [SerializeField] float shakeMagnetude = 0.05f;
    [SerializeField] Camera mainCamera;
    public bool isShaking;

   /* [Header("End Shake")]
    public float endshakeTime = 0.5f;
    public float endshakeMagnetude = 0.1f;*/

    private Vector3 cameraInitialPosition;
   // private Vector3 cameraInitialRotaion;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(this.gameObject);
        }
    }

    private void Start()
    {
        if (mainCamera == null)
        {
            mainCamera = GetComponent<Camera>();
        }
    }

    public void ShakeIt()
    {
        cameraInitialPosition = mainCamera.transform.position;
        isShaking = true;
        InvokeRepeating("StartCameraShaking", 0f, 0.005f);
        Invoke("StopCameraShaking", shakeTime);
    }

    /*public void ShakeItDeath()
    {
        cameraInitialPosition = mainCamera.transform.position;
        InvokeRepeating("StartEndCameraShaking", 0f, 0.005f);
        Invoke("StopEndCameraShaking", endshakeTime);
    }*/

    public void HalfSecondShake()
    {
        cameraInitialPosition = mainCamera.transform.position;
        InvokeRepeating("StartCameraShaking", 0f, 0.005f);
        Invoke("StopCameraShaking", 0.5f);
    }

    public void StartShaking()
    {
        cameraInitialPosition = mainCamera.transform.position;
        InvokeRepeating("StartCameraShaking", 0f, 0.005f);
    }

    public void StopShaking()
    {
        Invoke("StopCameraShaking", 0.1f);
    }

    void StartCameraShaking()
    {
        //float cameraShakingOffsetX = Random.value * shakeMagnetude * 2 - shakeMagnetude;
        //float cameraShakingOffsetY = Random.value * shakeMagnetude * 2 - shakeMagnetude;
        float cameraShakingOffsetZ = Random.value * shakeMagnetude * 2 - shakeMagnetude;
        Vector3 cameraIntermadiatePosition = mainCamera.transform.position;
       // cameraIntermadiatePosition.x += cameraShakingOffsetX;
        //cameraIntermadiatePosition.y += cameraShakingOffsetY;
        cameraIntermadiatePosition.z += cameraShakingOffsetZ;
        mainCamera.transform.position = cameraIntermadiatePosition;
    }

    void StopCameraShaking()
    {
        CancelInvoke("StartCameraShaking");
        mainCamera.transform.position = cameraInitialPosition;
        isShaking = false;
    }

   /* void StartEndCameraShaking()
    {
        float cameraShakingOffsetX = Random.value * endshakeMagnetude * 2 - endshakeMagnetude;
        float cameraShakingOffsetY = Random.value * endshakeMagnetude * 2 - endshakeMagnetude;
        Vector3 cameraIntermadiatePosition = mainCamera.transform.position;
        cameraIntermadiatePosition.x += cameraShakingOffsetX;
        cameraIntermadiatePosition.y += cameraShakingOffsetY;
        mainCamera.transform.position = cameraIntermadiatePosition;
    }

    void StopEndCameraShaking()
    {
        CancelInvoke("StartEndCameraShaking");
        mainCamera.transform.position = cameraInitialPosition;
    }*/

    /*IEnumerator Rotate(float duration)
    {
        Quaternion startRot = transform.rotation;
        float t = 0.0f;
        while (t < duration)
        {
            t += Time.deltaTime;
            transform.rotation = startRot * Quaternion.AngleAxis(t / duration * 360f, Vector3.right); //or transform.right if you want it to be locally based
            yield return null;
        }
        transform.rotation = startRot;
    }


    private bool flip;
    private float cameraShakingOffsetZ;
    void StartRotationalCameraShaking()
    {
       
        if (flip)
        {
            flip = false;
            cameraShakingOffsetZ = 1f * shakeMagnetudeRoation * 2 - shakeMagnetude;
        }
        else
        {
            flip = true;
            cameraShakingOffsetZ = -1f * shakeMagnetudeRoation * 2 - shakeMagnetude;
        }
        
        Vector3 cameraIntermadiateRotation = mainCamera.transform.eulerAngles;
        cameraIntermadiateRotation.z += cameraShakingOffsetZ;
        mainCamera.transform.rotation = Quaternion.Euler(cameraIntermadiateRotation);
    }

    void StopCameraRotaionShaking()
    {
        CancelInvoke("StartRotationalCameraShaking");
        mainCamera.transform.rotation = Quaternion.Euler(cameraInitialRotaion);
    }*/


}