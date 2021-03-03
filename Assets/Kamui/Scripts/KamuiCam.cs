using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class KamuiCam : MonoBehaviour
{
    public Material mat;
    public Camera cam;
    public GameObject quad;

    [Header("Spinning Radius")]
    [Range(0, 10)]public float _radiusS;

    [Header("Twist Radius")]
    [Range(0, 10)] public float _radiusT;

    [Range(0, 0.1f)] public float _weight;

    [Range(0, 3)] public float _twist;
    [Range(1, 4)] public int _shadowWeight;
    
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        cam = GetComponent<Camera>();

        Vector3 pos = quad.transform.position;

        pos = cam.WorldToScreenPoint(pos);
        pos.x /= source.width;
        pos.y /= source.height;

        Vector4 objPos = new Vector4(pos.x, pos.y, pos.z, 0);

        mat.SetVector("_objScreenPos", objPos);

        mat.SetFloat("_weight", _weight);
        mat.SetFloat("_twist", _twist);
        mat.SetFloat("_shadowWeight", _shadowWeight);
        mat.SetFloat("_radiusS", _radiusS);
        mat.SetFloat("_radiusT", _radiusT);
        Graphics.Blit(source, destination);
    }
}
