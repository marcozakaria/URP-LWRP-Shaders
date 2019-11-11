using UnityEngine;

/// <summary>
/// Parent class responsible for extracting beats from..
/// ..spectrum value given by AudioSpectrum.cs
/// </summary>
public class AudioSyncer : MonoBehaviour
{
    public float bias;
    public float timeStep;
    public float timeToBeat;
    public float restSmoothTime;

    private float m_previousAudioValue;
    private float m_audioValue;
    private float m_timer;

    protected bool m_isBeat;   

    private void Awake()
    {
        bias = Random.Range(5, 50);
    }

    private void Update()
    {
        OnUpdate();
    }

    /// <summary>
    /// Inherit this to cause some behavior on each beat
    /// </summary>
    public virtual void OnBeat()
	{
		//Debug.Log("beat");
		m_timer = 0;
		m_isBeat = true;
	}

	/// <summary>
	/// Inherit this to do whatever you want in Unity's update function
	/// Typically, this is used to arrive at some rest state..
	/// ..defined by the child class
	/// </summary>
	public virtual void OnUpdate()
	{ 
		// update audio value
		m_previousAudioValue = m_audioValue;
		m_audioValue = AudioSpectrum.spectrumValue;

		// if audio value went below the bias during this frame
		if (m_previousAudioValue > bias &&m_audioValue <= bias)
		{
			// if minimum beat interval is reached
			if (m_timer > timeStep)
				OnBeat();
		}

		// if audio value went above the bias during this frame
		if (m_previousAudioValue <= bias && m_audioValue > bias)
		{
			// if minimum beat interval is reached
			if (m_timer > timeStep)
				OnBeat();
		}

		m_timer += Time.deltaTime;
	}
	
}
