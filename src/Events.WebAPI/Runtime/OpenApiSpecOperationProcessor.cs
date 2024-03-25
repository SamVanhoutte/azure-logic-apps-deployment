namespace Events.WebAPI.Runtime;
using System.Reflection;
using NSwag.Generation.Processors;
using NSwag.Generation.Processors.Contexts;


public class OpenApiSpecOperationProcessor : IOperationProcessor
{
    private readonly bool includeAllOperations;
    private readonly string? apiType;

    public OpenApiSpecOperationProcessor(bool includeAllOperations = false, string? apiType = null)
    {
        this.includeAllOperations = includeAllOperations;
        this.apiType = apiType;
    }
        
    public bool Process(OperationProcessorContext context)
    {
        if (includeAllOperations)
        {
            return true;
        }
            
        // Looking for the method or controller to have the ApiType attribute defined

        ApiTypeAttribute? attribute = null;
        if (context.MethodInfo.IsDefined(typeof(ApiTypeAttribute), true))
        {
            // First we check the method (deepest level), as that can override the controller
            attribute = (ApiTypeAttribute?)context.MethodInfo.GetCustomAttribute(typeof(ApiTypeAttribute));
        }
        else
        {
            // If no attribute on the method, we check the controller
            if (context.ControllerType.IsDefined(typeof(ApiTypeAttribute), true))
            {
                attribute = (ApiTypeAttribute?)context.ControllerType.GetCustomAttribute(typeof(ApiTypeAttribute));
            }
        }

        // Neither the method, nor the controller have the attribute
        // So we return false as it should not be included
        if (attribute == null)
        {
            Console.WriteLine($"No attribute set on the operation {context.MethodInfo.Name}");
            return false;
        }

        // Since we found an attribute, we are now applying the logic where the method
        // will be included in the open api spec, when AlwaysInclude is on,
        // or when the ApiType matches the requested api type
        if (!string.IsNullOrEmpty(apiType))
        {
            var include = attribute.AlwaysInclude || apiType.Equals(attribute.ApiType, StringComparison.CurrentCultureIgnoreCase); 
            Console.WriteLine($"Attribute set on the operation {context.MethodInfo.Name}: {attribute.ApiType}.  Include? {include}");
            return include;
        }

        return attribute.AlwaysInclude;
    }
}