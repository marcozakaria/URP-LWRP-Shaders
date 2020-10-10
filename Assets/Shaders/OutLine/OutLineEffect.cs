using UnityEngine;

public class OutLineEffect : MonoBehaviour
{
    [SerializeField] Material mat;
    [SerializeField] bool createChild = false;

    void Start()
    {
        if (createChild)
        {
            PrePareChildOutLine();
        }
    }

    private void PrePareChildOutLine()
    {
        GameObject obj = Instantiate(this.gameObject, transform.position, transform.rotation, transform);
        obj.GetComponent<Renderer>().material = mat;
        obj.GetComponent<OutLineEffect>().enabled = false;
    }
    
}
