using UnityEngine;

public class SetPlayerPositionMat : MonoBehaviour
{
    [Header("Materials that needs player Position")]
    [SerializeField] Material[] materials;

    [Header("Player Settings")]
    [SerializeField] float speed = 1f;
    
    private Animator animator;
    private Transform mtransform;

    private void Start()
    {
    //    animator = GetComponent<Animator>();
        mtransform = this.transform;
    }

    private void Update()
    {
        UpdateInputPosition();

        foreach (Material mat in materials)
        {
            mat.SetVector("_PlayerPos", mtransform.position);
        }
    }

    void UpdateInputPosition()
    {
        if (Input.GetKey(KeyCode.D))
        {
      //      animator.SetBool("walk", true);
            mtransform.Translate(-mtransform.right * speed * Time.deltaTime);
        }
        else if (Input.GetKey(KeyCode.A))
        {
          //  animator.SetBool("walk", true);
            mtransform.Translate(mtransform.right * speed * Time.deltaTime);
        }
        else
        {
        //    animator.SetBool("walk", false);
        }
    }
}
