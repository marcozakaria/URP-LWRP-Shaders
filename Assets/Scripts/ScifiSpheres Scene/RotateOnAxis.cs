using UnityEngine;

public class RotateOnAxis : MonoBehaviour
{
    [SerializeField] Vector3 axisVector = default;

    private void Update()
    {
        transform.Rotate(axisVector);
    }
}
