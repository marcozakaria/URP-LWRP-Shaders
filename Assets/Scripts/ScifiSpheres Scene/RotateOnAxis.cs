using UnityEngine;

public class RotateOnAxis : MonoBehaviour
{
    [Header("Manule Rotate")]
    [SerializeField] LayerMask spheresLayer;
    [SerializeField] float speed = 1;
    private Camera mainCamera;

    [Header("Auto rotate")]
    [SerializeField] Vector3 axisVector = default;
    [SerializeField] bool autoRotate;

    private void Start()
    {
        mainCamera = Camera.main;
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            if (Physics.Raycast(mainCamera.ScreenPointToRay(Input.mousePosition),1000,spheresLayer))
            {
                transform.Rotate(Input.GetAxis("Mouse Y") * -speed, Input.GetAxis("Mouse X") * -speed, 0);// * Mathf.Deg2Rad);
            }
        }

        if (autoRotate)
        {
            transform.Rotate(axisVector);
        }
        
    }
}
