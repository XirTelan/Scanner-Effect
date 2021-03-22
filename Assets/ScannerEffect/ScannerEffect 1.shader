Shader "FullScreen/ScannerEffect"
{
	Properties
    {
		_ScanDistance("_ScanDistance", float) = 0
		_ScanWidth ("_ScanWidth",float) = 100
		_MidColor("Mid Color", Color) = (1, 1, 1, 0)
		_TrailColor("Trail Color", Color) = (1, 1, 1, 0)
		_LeadColor("Leading Edge Color", Color) = (1, 1, 1, 0)
		_LeadSharp("Leading Edge Sharpness", float) = 10	
		_DetailTex("Texture", 2D) = "white" {}
		_HBarColor("Horizontal Bar Color", Color) = (0.5, 0.5, 0.5, 0)
		[HideInInspector]
		_WorldSpaceScannerPos("_WorldSpaceScannerPos", Vector) = (0,0,0,0)
		[HideInInspector]
		_vectorA("Vector",float) = (0,0,0,0) 
		[HideInInspector]
	    _vectorC("Vector",float) = (0,0,0,0) 
		[HideInInspector]
	    _vectorD("Vector",float) = (0,0,0,0)
		[HideInInspector]
	    _vectorB("Vector",float) = (0,0,0,0) 
    }

    HLSLINCLUDE

    #pragma vertex Vert

    #pragma target 4.5
    #pragma only_renderers d3d11 playstation xboxone vulkan metal switch
    #include  "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/RenderPass/CustomPass/CustomPassCommon.hlsl"
 

    // The PositionInputs struct allow you to retrieve a lot of useful information for your fullScreenShader:
  // struct PositionInputs
   //{
   //    float3 positionWS;  // World space position (could be camera-relative)
   //    float2 positionNDC; // Normalized screen coordinates within the viewport    : [0, 1) (with the half-pixel offset)
   //    uint2  positionSS;  // Screen space pixel coordinates                       : [0, NumPixels)
   //    uint2  tileCoord;   // Screen tile coordinates                              : [0, NumTiles)
   //    float  deviceDepth; // Depth from the depth buffer                          : [0, 1] (typically reversed)
   //    float  linearDepth; // View space Z coordinate                              : [Near, Far]
   //};

    // To sample custom buffers, you have access to these functions:
    // But be careful, on most platforms you can't sample to the bound color buffer. It means that you
    // can't use the SampleCustomColor when the pass color buffer is set to custom (and same for camera the buffer).
    // float4 SampleCustomColor(float2 uv);
    // float4 LoadCustomColor(uint2 pixelCoords);
    // float LoadCustomDepth(uint2 pixelCoords);
    // float SampleCustomDepth(float2 uv);

    // There are also a lot of utility function you can use inside Common.hlsl and Color.hlsl,
    // you can check them out in the source code of the core SRP package.

	float3 _vectorA;
	float3 _vectorC;
	float3 _vectorD;
	float3 _vectorB;

	float _FieldSize;
	float4 _MidColor;
	float4 _TrailColor;
	float4 _LeadColor;
	float _LeadSharp;
	float _ScanDistance;
	float _ScanWidth;
	float4 _WorldSpaceScannerPos;
	float4 _HBarColor;
	sampler2D _DetailTex;
	float4 horizBars(float2 p)
	{
		return 1 - saturate(round(abs(frac(p.y * 100) * 2)));
	}

	float4 horizTex(float2 p)
	{
		return tex2D(_DetailTex, float2(p.x * 30, p.y * 40));
	}


		

    float4 FullScreenPass(Varyings varyings) : SV_Target
    {
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
        float depth = LoadCameraDepth(varyings.positionCS.xy);
        PositionInputs posInput = GetPositionInput(varyings.positionCS.xy, _ScreenSize.zw, depth, UNITY_MATRIX_I_VP, UNITY_MATRIX_V);
        float3 viewDirection = GetWorldSpaceNormalizeViewDir(posInput.positionWS);
		float viewDirectionWS = GetWorldSpaceViewDir(posInput.positionWS);
        float4 color = float4(0.0, 0.0, 0.0, 0.0);
	
        // Load the camera color buffer at the mip 0 if we're not at the before rendering injection point
        if (_CustomPassInjectionPoint != CUSTOMPASSINJECTIONPOINT_BEFORE_RENDERING)
            color = float4(CustomPassLoadCameraColor(varyings.positionCS.xy, 0), 1);
        // Add your custom pass code here
		float3 abu = lerp(_vectorA, _vectorB, posInput.positionNDC.y);
		float3 dcu = lerp(_vectorD, _vectorC,  posInput.positionNDC.y);	
		float3 Out= lerp(abu, dcu,  posInput.positionNDC.x);
		float linearDepth =Linear01Depth(posInput.deviceDepth,_ZBufferParams);
		float3 wsDir = Out*linearDepth;
		float3 wsPos = _WorldSpaceCameraPos+ wsDir;

		half4 scannerCol = half4(0, 0, 0, 0);

				float dist = distance(wsPos, _WorldSpaceScannerPos);

				if (dist < _ScanDistance && dist > _ScanDistance - _ScanWidth && linearDepth < 1)
				{
					float diff = 1 - (_ScanDistance - dist) / (_ScanWidth);
					half4 edge = lerp(_MidColor, _LeadColor, pow(diff, _LeadSharp));
					scannerCol = lerp(_TrailColor, edge, diff) + horizBars(posInput.positionNDC) * _HBarColor;
					scannerCol *= diff;
				}

				return color + scannerCol;
    }


    ENDHLSL

    SubShader
    {
        Pass
        {
            Name "Custom Pass 0"

            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            HLSLPROGRAM
			
                #pragma fragment FullScreenPass
            ENDHLSL
        }
    }
    Fallback Off
}
