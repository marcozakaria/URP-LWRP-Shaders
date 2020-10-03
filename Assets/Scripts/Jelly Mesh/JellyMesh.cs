using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class JellyMesh : MonoBehaviour
{
    [SerializeField] float Intinsty = 1;
    [SerializeField] float Mass = 1;
    [SerializeField] float Stiffness = 1;
    [SerializeField] float damping = 0.7f;

    private Mesh originalMesh, cloneMesh;
    private MeshRenderer meshRenderer;
    private Rigidbody rg;

    private JellyVertex[] jv;
    private Vector3[] vertexArray;

    private void Start()
    {
        originalMesh = GetComponent<MeshFilter>().sharedMesh;
        cloneMesh = Instantiate(originalMesh);
        GetComponent<MeshFilter>().sharedMesh = cloneMesh;
        meshRenderer = GetComponent<MeshRenderer>();
        rg = GetComponent<Rigidbody>();

        jv = new JellyVertex[cloneMesh.vertices.Length];
        for (int i = 0; i < cloneMesh.vertices.Length; i++)
        {
            jv[i] = new JellyVertex(i, transform.TransformPoint(cloneMesh.vertices[i]));
        }
    }

    private void FixedUpdate()
    {
        if (!rg.IsSleeping())
        {
            vertexArray = originalMesh.vertices;
            for (int i = 0; i < jv.Length; i++)
            {
                Vector3 target = transform.TransformPoint(vertexArray[jv[i].id]);
                float intensty = (1 - (meshRenderer.bounds.max.y - target.y) / meshRenderer.bounds.size.y) * Intinsty;
                jv[i].Shake(target, Mass, Stiffness, damping);
                target = transform.InverseTransformPoint(jv[i].position);
                vertexArray[jv[i].id] = Vector3.Lerp(vertexArray[jv[i].id], target, intensty);
            }

            cloneMesh.vertices = vertexArray;
        }
    }

    public class JellyVertex
    {
        public int id;
        public Vector3 position;
        public Vector3 velocity, force;

        public JellyVertex(int _id , Vector3 _pos)
        {
            id = _id;
            position = _pos;
        }

        public void Shake(Vector3 target, float m ,float s,float d)
        {
            force = (target - position) * s;
            velocity = (velocity + force / m) * d;
            position += velocity;
            if ((velocity + force +force /m).magnitude < 0.001f)
            {
                position = target;
            }
        }
    }
}
