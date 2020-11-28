using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//https://catlikecoding.com/unity/tutorials/basics/compute-shaders/

public class GPUGraph : MonoBehaviour
{

	[SerializeField, Range(10, 200)]
	int resolution = 10;

	[SerializeField]
	FunctionLibrary.FunctionName function = default;

	public enum TransitionMode { Cycle, Random }

	[SerializeField]
	TransitionMode transitionMode = TransitionMode.Cycle;

	[SerializeField, Min(0f)]
	float functionDuration = 1f, transitionDuration = 1f;


	float duration;

	bool transitioning;

	FunctionLibrary.FunctionName transitionFunction;

	void Update()
    {
		duration += Time.deltaTime;
		if (transitioning)
		{
			if (duration >= transitionDuration)
			{
				duration -= transitionDuration;
				transitioning = false;
			}
		}
		else if (duration >= functionDuration)
		{
			duration -= functionDuration;
			transitioning = true;
			transitionFunction = function;
			PickNextFunction();
		}
	}

	void PickNextFunction() 
	{

	}
}
