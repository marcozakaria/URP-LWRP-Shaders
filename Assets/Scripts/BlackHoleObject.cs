using UnityEngine;

public class BlackHoleObject : MonoBehaviour
{
    [SerializeField] Material[] materialToUpdate;
    [Range(0f, 1f)]
    [SerializeField] float rangeProgress;
    [Range(0f, 20f)]
    [SerializeField] float range = 6;

    private void Update()
    {
        foreach (Material mat in materialToUpdate)
        {
            mat.SetVector("_HolePosition", transform.position);
            mat.SetFloat("_progress", rangeProgress * 1.2f);
            mat.SetFloat("_Range", range);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawWireSphere(transform.position, range);
    }
}
