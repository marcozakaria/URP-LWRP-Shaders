using UnityEngine;

[ExecuteInEditMode]
public class ClipingPlane : MonoBehaviour
{
	public Renderer[] renderers;

	void Update()
	{

		Vector3 pos = transform.position;
		Vector3 normal = transform.up;
		for (int i = 0; i < renderers.Length; i++)
		{
			renderers[i].material.SetVector("_PlanePos", pos);
			renderers[i].material.SetVector("_PlaneNormal", normal);
		}
	}
}
