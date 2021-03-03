Shader "Custom/Kamui"
{
    Properties
    {
        _WeightTex ("Squeeze Tex", 2D) = "white"{}
        _ShadowTex ("ShadowTex", 2D) = "white"{}
    }

    SubShader
    {

        Tags { "Queue"="Transparent+100" }
        
        GrabPass{ "_BgTex" }

        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            sampler2D _BgTex;
            float4 _BgTex_TexelSize;
            sampler2D _WeightTex;
            float4 _WeightTex_ST;
            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            uniform float4 _objScreenPos;
            uniform float _weight;
            uniform float _radiusS;
            uniform float _shadowWeight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _ShadowTex);
                
                return o;
            }

            float Curve(float i){
                if(i < _radiusS){
                    return i * (_radiusS - i) + 0.05;
                    //return (i +_radiusS) * (_radiusS - i) + 0.05;
                }else{
                    return 0;
                }
            }

            float ShadowScope(float i){
                if(i < _radiusS){
                    return i / _radiusS;
                }else{
                    return 1;
                }
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 grabScreenPos = i.grabPos / i.grabPos.w;

				float4 _offset = i.grabPos - _objScreenPos * i.grabPos.w;
                _offset.y *= _ScreenParams.y / _ScreenParams.x;
				float offsetLen = sqrt(_offset.x * _offset.x + _offset.y * _offset.y);

                float4 offsetDir = normalize(float4(_offset.x, _offset.y, 0, 0));

                float radian = atan2(_offset.y, _offset.x);

                float inOutDir = tex2D(_WeightTex, fixed2(radian / 4, radian / 3.14)) * sin(radian / 0.125) + 0.5;
                //float inOutDir = sin(radian / 0.125) + 0.5;
                offsetDir *= inOutDir * _weight * Curve(offsetLen);

                float shadow = tex2D(_ShadowTex, i.uv + offsetDir);
                shadow = max(shadow, ShadowScope(offsetLen));
                if(shadow != 1)
                    shadow  = pow(shadow, _shadowWeight);

                fixed4 col = tex2D(_BgTex, grabScreenPos + offsetDir);
                return col * shadow;
            }

            ENDCG
        }

        GrabPass{ "_secondPass"}

		Pass{
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 grabPos : TEXCOORD0;
            };

            sampler2D _secondPass;
            float4 _secondPass_TexelSize;
            uniform float4 _objScreenPos;
            uniform float _twist;
            uniform float _twistWeight;
            uniform float _radiusT;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            float Curve(float i){
                if( i < 0.2){
                    return cos(i * 3.14 / (2 * _radiusT)) * (1.2 - i);
                }else if(i < _radiusT){
                    return cos(i * 3.14 / (2 * _radiusT));
                    //return (i - _radiusT) * (_radiusT + i);
                }else{
                    return 0;
                }
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 grabScreenPos = i.grabPos / i.grabPos.w;
                
				float4 _offset = i.grabPos - _objScreenPos * i.grabPos.w;

                _offset.y *= _ScreenParams.y/_ScreenParams.x;
				float offsetLen = sqrt(_offset.x * _offset.x + _offset.y * _offset.y);

				float curRadian = atan2(_offset.y, _offset.x);
                float deltaRadian = _twist * Curve(offsetLen);

				float tarRadian = curRadian - deltaRadian;

				float4 dest = float4(cos(tarRadian), sin(tarRadian),0,0) * offsetLen / i.grabPos.w;
                dest.y /= _ScreenParams.y / _ScreenParams.x;

                fixed4 col = tex2D(_secondPass, _objScreenPos + dest);
                return col;

            }
            ENDCG	
		}

    }
}
