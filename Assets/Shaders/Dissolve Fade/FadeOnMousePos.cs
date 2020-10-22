using UnityEngine;

public class FadeOnMousePos : MonoBehaviour
{
    [SerializeField] MeshRenderer[] Materials;
    private Camera mainCamera;
    private Vector3 newPos;

    void Start()
    {
        mainCamera = Camera.main;
    }
 
    void Update()
    {

        newPos = mainCamera.ScreenToWorldPoint(new Vector3(Input.mousePosition.x, Input.mousePosition.y, 10f));
        for (int i = 0; i < Materials.Length; i++)
        {
            Materials[i].material.SetVector("_WorldPos", newPos);
        }
    }
}
