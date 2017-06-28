Shader "Blobsters/MainCC" {
	Properties {
	    _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _DecalTex ("Decal Texture", 2D) = "black" {}
        _MaskTex ("Mask Texture", 2D) = "black" {}
        _ColorR ("Red Color", Color) = (1,0,0,1)
        [MaterialToggle]_RangeR ("(R)Range", range (0,1) ) = 1
        _ColorG ("Green Color", Color) = (0,1,0,1)
        [MaterialToggle]_RangeG ("(G)Range", range (0,1) ) = 1
        _ColorB ("Blue Color", Color) = (0,0,1,1)
        [MaterialToggle] _RangeB ("(B)Range", range (0,1) ) = 1
        
        
             }    
     SubShader {
     
          Tags { 
              "RenderType"="Transparent"  
              "IgnoreProjector"="False" 
              "CanUseSpriteAtlas"="True" 
              "PreviewType"="Plane" 
		       "Queue" = "Transparent"}
		       
		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		       
         CGPROGRAM
         #pragma surface surf Lambert alpha
         #pragma target 2.0
 
         sampler2D _MainTex, _MaskTex, _DecalTex;
         fixed4 _Color,_ColorR,_ColorG,_ColorB;
         float _RangeR, _RangeG, _RangeB;
             
         struct Input {
             float2 uv_MainTex;
             float2 uv_MaskTex;
             float2 uv_DecalTex;
             float4 color : COLOR;
         };            
 
         void surf (Input IN, inout SurfaceOutput o) {                
            fixed4 main = tex2D(_MainTex, IN.uv_MainTex);
            fixed4 mask = tex2D(_MaskTex, IN.uv_MaskTex);
            fixed4 dec = tex2D(_DecalTex, IN.uv_DecalTex);
            
            //mask.r *= _RangeR;           
            half3 cr = main.rgb * _ColorR;
            half3 cg = main.rgb * _ColorG;
            half3 cb = main.rgb * _ColorB;
            main.rgb *= _Color;
                        
            half r = mask.r;
            half g = mask.g;
            half b = mask.b;
            
            

            half minv = min((r * sign(_RangeR)) + (g * sign(_RangeG)) + (b * sign(_RangeB)), 1)	;
                       

            half3 cf = lerp(lerp(cr, cg, g*(r+g)), cb, b*(r+g+b));
            half3 c = lerp(main.rgb, cf, minv);

            
             o.Albedo = c.rgb;
             o.Alpha = main.a;
             
          }
         ENDCG
     }
     Fallback "Sprites/Default"
 }