Shader "Custom/Hundred People Plan/ Flowmap Water"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white"{}
        _Color("Tint", Color) = (1, 1, 1, 1)
        _FlowMap("Flow Map", 2D) = "white"{}
        _FlowSpeed("Flow Speed", Range(0, 10)) = 0.1
        _TimeSpeed("Time Speed", Range(0, 10)) = 1
        //[Toggle] 是在控制面版上加一个可选项，是否勾选
        [Toggle]_reverse_flow("Reverrse Flow", Int) = 0
        //_Noise("Noise Map", 2D) = "black"{}
    }
    SubShader
    {
       Tags{"Queue" = "Opaque"  "IgnoreProjector" = "True"  "RenderType" = "Opaque" }

       Cull Off
       Lighting Off
       ZWrite On

       Pass
       {
           CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma shader_feature _REVERSE_FLOW_ON
           #include "UnityCG.cginc"

           fixed4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           sampler2D _FlowMap;
           float _FlowSpeed;
           float _TimeSpeed;
           int _reverse_flow;

           struct appdata_t
           {
               float4 vertex : POSITION;
               float2 texcoord : TEXCOORD0; 
           };
           
           struct v2f
           {
               float4 vertex : SV_POSITION;
               half2 uv : TEXCOORD0;
           };

           v2f vert(appdata_t i)
           {
               v2f o;

               o.vertex = UnityObjectToClipPos(i.vertex);
               o.uv = i.texcoord;

               return o;
           }

           fixed4 frag(v2f i) : SV_Target
           {
               //纹理的默认取值范围（0-1）转换为方向向量所需的对称范围（-1-1）
               float3 flowDir = tex2D(_FlowMap, i.uv) * 2.0 - 1.0;

               //FlowSpeed影响向量场的强度，值越大，不同位置流速差越明显
               //这个负号不是 “必须” 的，只是开发时的方向适配，
               //如果去掉负号，流动方向会整体反转
               //是不是关于Unity和虚幻的flowmap对应的数值有点不一样所以进行一定的改进
               flowDir *= -_FlowSpeed;

               //如果勾选，则反转流向
               #ifdef _REVERS_FLOW_ON
                   flowDir *= -1;
               #endif
               
               float phase0 = frac(_Time.y * 0.1 * _TimeSpeed);
               float phase1 = frac(_Time.y * 0.1 * _TimeSpeed + 0.5);

               //主要贴图用的uv
               float2 tiling_uv = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;

               half3 tex0 = tex2D(_MainTex, tiling_uv - flowDir.xy * phase0).rgb;
               half3 tex1 = tex2D(_MainTex, tiling_uv - flowDir.xy * phase1).rgb;

               //构造函数计算随波形函数变化的权值， 
               //让两个纹理能交替变化不会出现突变的情况
               float flowLerp = abs((0.5 - phase0) / 0.5);
               half3 finalColor = lerp(tex0, tex1, flowLerp);

               fixed4 c = float4(finalColor, 1.0) * _Color;

               return c;

           }
          
           ENDCG

       }
    }
    FallBack "Diffuse"
}
