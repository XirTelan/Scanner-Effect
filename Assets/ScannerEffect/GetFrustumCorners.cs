using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetFrustumCorners : MonoBehaviour
{
    public Material material;
    Camera _camera;
    private void Awake() => _camera = Camera.main;
    // Start is called before the first frame update
    void Update()
    {
        Vector3[] frustumCorners = new Vector3[4];
        Vector3[] frustumCornersWorldPos = new Vector3[4];
        _camera.CalculateFrustumCorners(new Rect(0, 0, 1, 1), _camera.farClipPlane, Camera.MonoOrStereoscopicEye.Mono, frustumCorners);

        for (int i = 0; i < 4; i++)
        {
            var worldSpaceCorner = _camera.transform.TransformVector(frustumCorners[i]);
            frustumCornersWorldPos[i] = worldSpaceCorner;
        }
        material.SetVector("_vectorA", frustumCornersWorldPos[0]);
        material.SetVector("_vectorB", frustumCornersWorldPos[1]);
        material.SetVector("_vectorC", frustumCornersWorldPos[2]);
        material.SetVector("_vectorD", frustumCornersWorldPos[3]);

    }
}
