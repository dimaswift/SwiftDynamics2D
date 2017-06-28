Shader "Blobsters/Main3D" {
	Properties {
	    _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _DecColor ("Main Color", Color) = (1,1,1,1)
        _DecalTex ("Decal Texture", 2D) = "black" {}
             }    
     SubShader {
     
          Tags { 
              "RenderType"="Opaque"  
              "IgnoreProjector"="False" 
              }
		       
		Lighting Off
		
		       
         CGPROGRAM
         
         #pragma surface surf Lambert
         #pragma target 2.0
 
         sampler2D _MainTex, _DecalTex;
         fixed4 _Color, _DecColor;
             
         struct Input {
             float2 uv_MainTex;
             float2 uv_DecalTex;
             float4 color : COLOR;
         };            
 
         void surf (Input IN, inout SurfaceOutput o) {                
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed4 dec = tex2D(_DecalTex, IN.uv_DecalTex) * _DecColor;
            
            c.rgb = lerp(c.rgb, dec.rgb, dec.a);
            
             o.Albedo = c.rgb *= c.a ;
             o.Alpha = c.a;
             
          }
         ENDCG
     }
     Fallback "Sprites/Default"
 }