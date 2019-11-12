using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class AudioSuncColorImage : AudioSyncer
{
    [ColorUsageAttribute(true, true)]
    public Color[] beatColors;
    [ColorUsageAttribute(true, true)]
    public Color restColor;

    private int m_randomIndx;
    private Image image;

    private void Start()
    {
        image = GetComponent<Image>();
        restColor = image.color;
        bias = Random.Range(5, 50);
    }

    public override void OnUpdate()
    {
        base.OnUpdate();

        if (m_isBeat) return;

        image.color = Color.Lerp(image.color, restColor, restSmoothTime * Time.deltaTime);
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
        Color _curr = image.color;
        Color _initial = _curr;
        float _timer = 0;

        while (_curr != _target)
        {
            _curr = Color.Lerp(_initial, _target, _timer / timeToBeat);
            _timer += Time.deltaTime;

            image.color = _curr;

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
