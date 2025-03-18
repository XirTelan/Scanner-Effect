using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoTransition : MonoBehaviour
{
    public Material material;
    public float transitionDuration = 2f;
    private float startTime;
    private bool isTransitioning = false;


    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            startTime = Time.time;
            isTransitioning = true;
        }


        if (isTransitioning)
        {
            float t = (Time.time - startTime) / transitionDuration;

            float value = Mathf.Lerp(0f, 1.1f, t);

            material.SetFloat("_transition", value);

            if (t >= 1f)
            {
                isTransitioning = false;
            }
        }
    }
}
