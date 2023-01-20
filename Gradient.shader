Shader "Unlit/Gradient"{ // path (not asset path) (identifier) (name)
    Properties { // properties of shader that will appear
        _TopColor ("Top Color", Color) = (1,1,1,1)
        _BottomColor ("Bottom Color", Color) = (0,0,0,1)
        _Threshold ("Threshold", Range(0,1)) = 0
        _Center ("Center", Range(-1,1)) = 0
        _Angle ("Angle", Range(0,360)) = 0
    }
    SubShader{
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass{
            CGPROGRAM
            
            // what functions to use for what
            #pragma vertex vert // use vert function for vertex shader
            #pragma fragment frag // use frag function for fragment shader

            #include "UnityCG.cginc"

            // struct of vertex
            struct vertexdata{ 
                // float(number) = float that takes (number) amount of input
                // float2 = 1,1; float3 = 1,1,1; float4 = 1,1,1,1...
                float4 position : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : COLOR;
                float2 uv : TEXCOORD0; // uv channel 0
            };

            // struct for sending data from vertex shader to fragment shader
            struct interpolators{
                float4 vertex : SV_POSITION; // clip space vertex position
                float2 coord : TEXCOORD0;
            };

            // property variable declaration
            float4 _TopColor;
            float4 _BottomColor;
            float1 _Threshold;
            float1 _Center;
            float1 _Angle;
            
            // vertex shader - foreach(vertex)
            interpolators vert (vertexdata v){         
                interpolators o; // new interpolators object (output)
                
                // UNITY_MATRIX_MVP model-view-projection (local to clip space)
                o.vertex = UnityObjectToClipPos(v.position); // transforms from local to clip space
                
                o.coord = v.uv;
                return o;
            }
            
            float2 rotateUV(interpolators i, float rotation){
                return float2(
                    cos(rotation) * (i.coord.x - .5) + sin(rotation) * (i.coord.y - .5) + .5,
                    cos(rotation) * (i.coord.y - .5) - sin(rotation) * (i.coord.x - .5) + .5
                );
            }
            
            // float (32-bit float)
            // half (16-bit float)
            // fixed (11-bit, fixed-point, kinda, ish, mostly not used?)

            // fragment shader - foreach(fragment)
            float4 frag (interpolators i) : SV_Target{
                float2 coords = rotateUV(i, _Angle * (UNITY_TWO_PI / 360));
                const float t = smoothstep(0 + _Threshold, 1 - _Threshold, coords.y + _Center);
                return lerp(_BottomColor, _TopColor, t);
            }
            ENDCG
        }
    }
}
