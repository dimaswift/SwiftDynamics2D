// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Blobsters/MainCCUnlit"
{
	Properties
	{
	    _Color ("Tint", Color) = (1,1,1,1)
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_DecalTex ("Decal Texture", 2D) = "black" {}
		_MaskTex ("Mask Texture", 2D) = "black" {}
        _ColorR ("Red Color", Color) = (1,0,0,1)
        [MaterialToggle]_RangeR ("(R)Range", range (0,1) ) = 1
        _ColorG ("Green Color", Color) = (0,1,0,1)
        [MaterialToggle]_RangeG ("(G)Range", range (0,1) ) = 1
        _ColorB ("Blue Color", Color) = (0,0,1,1)
        [MaterialToggle] _RangeB ("(B)Range", range (0,1) ) = 1
		
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			uniform fixed4 _Color, _ColorR, _ColorG, _ColorB;
			uniform float _RangeR, _RangeG, _RangeB;
			uniform sampler2D _MainTex, _DecalTex, _MaskTex;
			uniform float4 _MainTex_ST, _DecalTex_ST, _MaskTex_ST;
			
			struct vertexInput{
			
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
		    };

			struct vertexOutput{
			
				float4 pos   : SV_POSITION;
				fixed4 color    : COLOR;
				fixed2 texcoord  : TEXCOORD0;
				
			};
			
			
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				UNITY_INITIALIZE_OUTPUT(vertexOutput,o); 
				o.pos = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
								
				return o;
			}

			

			float4 frag(vertexOutput i) : SV_Target{
			
				fixed4 main = tex2D(_MainTex, _MainTex_ST.xy * i.texcoord.xy + _MainTex_ST.zw);
				fixed4 dec = tex2D(_DecalTex, _DecalTex_ST.xy * i.texcoord.xy + _DecalTex_ST.zw);
				fixed4 mask = tex2D(_MaskTex, _MaskTex_ST.xy * i.texcoord.xy + _MaskTex_ST.zw);
				            
            fixed4 cr = main * _ColorR;
            fixed4 cg = main * _ColorG;
            fixed4 cb = main * _ColorB;
            
            main.rgb *= _Color;
                        
            fixed r = mask.r;
            fixed g = mask.g;
            fixed b = mask.b;
            
            

            fixed minv = min((r * sign(_RangeR)) + (g * sign(_RangeG)) + (b * sign(_RangeB)), 1) * mask.a;
                       

            fixed3 cf = lerp(lerp(cr, cg, g*(r+g)), cb, b*(r+g+b));
            fixed3 c = lerp(main.rgb, cf, minv);
            c.rgb = lerp(c.rgb, dec.rgb, dec.a);
            c.rgb *= main.a;
            
				return float4(c.rgb,main.a);
			}
		ENDCG
		}
	}
}
