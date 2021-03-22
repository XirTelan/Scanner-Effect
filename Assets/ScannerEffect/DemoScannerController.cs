using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DemoScannerController : MonoBehaviour
{
    public Material material;
    private float _scanDistance;
    public float Speed;
    bool _scanning;
    Camera _camera;
    private void Awake() => _camera = Camera.main;
    void Update()
    {
        if (_scanning)
        {
            _scanDistance += Time.deltaTime * Speed;
            material.SetFloat("_ScanDistance", _scanDistance);
        }

        if (Input.GetKeyDown(KeyCode.C))
        {
            _scanning = true;
            _scanDistance = 0;
            material.SetFloat("_ScanDistance", _scanDistance);
        }

        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = _camera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {
                _scanning = true;
                _scanDistance = 0;
                material.SetFloat("_ScanDistance", _scanDistance);
                material.SetVector("_WorldSpaceScannerPos", hit.point);
            }
        }
    }
    private void OnDisable()
    {
        _scanDistance = 0;
        material.SetFloat("_ScanDistance", _scanDistance);
    }

}
