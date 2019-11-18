using UnityEngine;

public class RotateOnAxis : MonoBehaviour
{
    [Header("Manule Rotate")]
    [SerializeField] LayerMask spheresLayer;
    [SerializeField] float speed = 1;
    [SerializeField] SphereCollider myCollider;
    private Camera mainCamera;

    [Header("Auto rotate")]
    [SerializeField] Vector3 axisVector = default;
    [SerializeField] bool autoRotate;

    private void Start()
    {
        mainCamera = Camera.main;
        myCollider = GetComponent<SphereCollider>();
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            RaycastHit hit;
            if (Physics.Raycast(mainCamera.ScreenPointToRay(Input.mousePosition),out hit,1000,spheresLayer))
            {
                if (hit.collider == myCollider)
                {
                    transform.Rotate(Input.GetAxis("Mouse Y") * -speed, Input.GetAxis("Mouse X") * -speed, 0);// * Mathf.Deg2Rad);
                }
               
            }
        }

        if (autoRotate)
        {
            transform.Rotate(axisVector);
        }
        
    }
}
