// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Blobsters/Bubbles"
{
        Properties
        {
                _Cube ("Cubemap", CUBE) = "" {}
                _RimIntensity("Rim Intensity", Range(0,3)) = 1
                _RimColor("Rim Colour", Color) = (0,0,0,1)
                _RimPower("Rim Power", Range(0,4)) = 1
                _Curvature("Curvature", Range(0.001, 0.02)) = 0.1
                _SpecCol("Spec Colour", Color) = (1,1,1,1)
                _Spec("Spec Intensity", Range(0,1)) = 0.5
                _WobbleAmount("Wobble Amount", Range(0,2)) = 1
                _WobbleSpeed("Wobble Speed", Range(0,5)) = 1
                _Transparency ("Transparency", Range(0,1)) = 1
                _Noise ("Noise", 2D) = "white"{}
        }
        SubShader
        {
                Pass
                {
                        Tags {"Queue"="Transparent+1" "IgnoreProjector"="True" "RenderType"="Transparent"}
                        Blend SrcAlpha OneMinusSrcAlpha
                        Ztest off
                       
                        CGPROGRAM

                        #pragma vertex vert
                        #pragma fragment frag
                        #include "UnityCG.cginc"
                       
                        uniform samplerCUBE _Cube;
                        half _RimIntensity;
                        fixed3 _RimColor;
                        half _RimPower;
                        fixed3 _SpecCol;
                        half _Spec;
                        half _Curvature;
                        half _WobbleAmount;
                        half _WobbleSpeed;
                        half _Transparency;
                        sampler2D _Noise;
 
                        struct v2f
                        {
                                float4 pos: SV_POSITION;
                                float4 position: TEXCOORD2;
                                float2 uv: TEXCOORD0;
                                float2 uv2: TEXCOORD1;
                                half t0: TEXCOORD3;
                                half t1: TEXCOORD4;
                                half t2: TEXCOORD5;
                        };
 
                        v2f vert (appdata_base v)
                        {
                                v2f o;
                              
                                //o.position = mul(UNITY_MATRIX_MVP, v.vertex);
                                o.pos = UnityObjectToClipPos(v.vertex);
                                float3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
                                o.uv = v.texcoord.xy;
                                o.uv2 = o.uv * 2.5 - 1.25;
                                o.t0 = sin(_Time.y * 1.9 * _WobbleSpeed) * 0.46 * _WobbleAmount; //controller times with abstract values
                                o.t1 = sin(_Time.y * 2.4 * _WobbleSpeed) * 0.49 * _WobbleAmount;
                                o.t2 = cos(_Time.y * 1.4 * _WobbleSpeed) * 0.57 * _WobbleAmount;
                                return o;
                        }
                       
                        half meta(half2 d, half r)
                        {
                                return r / dot(d, d);
                        }
 
                        half4 frag (v2f i) : COLOR
                        {                      
                                //metaball creation
                                half r = meta(i.uv2 + half2(i.t0, i.t2), 0.31) *
                                meta(i.uv2 - half2(i.t0, i.t1), 0.24) *
                                meta(i.uv2 + half2(i.t1, i.t2), 0.56);
                               
                                half3 noise = tex2D(_Noise, i.uv.xy).xyz;
                                r *= max(0,(noise.r * 10)) * noise.g;
                                //3D math
                                half z = sqrt(r * _Curvature);
                                half3 normal = normalize(float3(i.uv.x * r, i.uv.y * r, z * 2));
                               
                                //Rim and Reflection
                                half3 fresnel = saturate(dot(float3(0,0,1), normal));
                                half3 rim = _RimColor * pow(fresnel, _RimPower) * _RimIntensity;
                                half4 reflection = texCUBE(_Cube, reflect(half3(0,0,1),normal));
                               
                                //diffuse
                                half NDotL = dot(normal + 0.5, half3(0,1,0));
                                half4 diff = reflection * NDotL * 0.5;
                               
                                //specular
                                half3 spec = saturate(_SpecCol * z * _Spec);
                               
                                //final comp
                                half4 result;
                                result.rgb = diff + rim + spec;
                                result.a = ((_Transparency + rim) + spec) * step(0.4, r);
                                return result;
                        }
 
                        ENDCG
                }
        }
}