using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class Billboard : MonoBehaviour
{
    public Camera cam;
    public Vector3 offset = new Vector3(0, 180);

    void Update()
    { 
        transform.LookAt(cam.transform);
        transform.Rotate(offset, Space.Self);
    }
}
