#if !defined(TESSELLATION_INCLUDED)
#define TESSELLATION_INCLUDED

[UNITY_domain("tri")]
[UNITY_outputcontrolpoints(3)]  
[UNITY_outputtopology("triangle_cw")]   // triangles are clock wise or not
appdata MyHullProgram (InputPatch<appdata, 3> patch,
	uint id : SV_OutputControlPointID) 
{
    return patch[id];
}

#endif