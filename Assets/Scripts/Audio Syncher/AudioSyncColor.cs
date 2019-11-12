using System.Collections;
using UnityEngine;

public class AudioSyncColor : AudioSyncer
{
    [ColorUsageAttribute(true, true)]
    public Color[] beatColors;
    private Color restColor;

    private int m_randomIndx;
    private Material material;

    private void Start()
    {
        material = GetComponent<MeshRenderer>().material;
        restColor = material.color;
        bias = Random.Range(5, 50);
    }

    public override void OnUpdate()
    {
        base.OnUpdate();

        if (m_isBeat) return;

        material.color = Color.Lerp(material.color, restColor, restSmoothTime * Time.deltaTime);
    }

    public override void OnBeat()
    {
        base.OnBeat();

        Color _c = RandomColor();

        StopCoroutine("MoveToColor");
        StartCoroutine("MoveToColor", _c);
    }

    private IEnumerator MoveToColor(Color _target)
	{
		Color _curr = material.color;
		Color _initial = _curr;
		float _timer = 0;
		
		while (_curr != _target)
		{
			_curr = Color.Lerp(_initial, _target, _timer / timeToBeat);
			_timer += Time.deltaTime;

			material.color = _curr;

			yield return null;
		}

		m_isBeat = false;
	}

	private Color RandomColor()
	{
		if (beatColors == null || beatColors.Length == 0) return Color.white;
		m_randomIndx = Random.Range(0, beatColors.Length);
		return beatColors[m_randomIndx];
	}
}
