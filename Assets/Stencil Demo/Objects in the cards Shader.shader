Shader "Hundred People Plan/(Mask)Objects in the cards Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (0.5, 0.5, 0.5,1)
        _MainTex ("Base (RGB)", 2D) = "white"{}
        _Ramp ("Toon Ramp (RGB)", 2D) = "gray"{}
        _ID("Mask ID", Int) = 1
    }
   
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue" = "Geometry+2"}
        LOD 200
        //ColorMask A

        Stencil {
            Ref [_ID]
            Comp equal
        }

        //用表面着色器写的
        CGPROGRAM
        #pragma surface surf ToonRamp
        sampler2D _Ramp;
        //还有这里的一最末尾少一个d让我没有正确运行这个效果还是要注意一下拼写
        //就算没有物体变紫的时候也要
        #pragma lighting ToonRamp exclude_path:forward

        //inline - 内联函数关键字
        //告诉编译器，调用这个函数时，直接将函数体代码 “嵌入” 到调用处，
        //而不是常规的函数调用（减少函数调用的性能开销）。
        //内联嵌入：编译器会直接把函数体代码替换到这里，没有跳转

        //利用的表面着色器作为输入
        inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
        {
            #ifndef USING_DIRECTIONAL_LIGHT
            lightDir = normalize(lightDir);
            #endif

            half d = dot (s.Normal, lightDir) * 0.5 + 0.5;
            half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;

            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
            c.a = 0;
            return c;
        }

        sampler2D _MainTex;
        float4 _Color;

        struct Input {
            float2 uv_MainTex : TEXCOORD0;
        };

        //这里的大小写让我没运行出来，还是要注意一下拼写，
        //就算没有物体变紫的时候也要
        void surf (Input IN, inout SurfaceOutput o){
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG

    }
    FallBack "Diffuse"
}
