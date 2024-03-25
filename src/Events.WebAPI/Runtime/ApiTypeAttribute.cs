namespace Events.WebAPI.Runtime;

[AttributeUsage(AttributeTargets.All)]
public class ApiTypeAttribute : Attribute
{
    private readonly string? apiType;
    private readonly bool alwaysInclude;

    public ApiTypeAttribute(string? apiType = null, bool alwaysInclude = false)
    {
        this.apiType = apiType;
        this.alwaysInclude = alwaysInclude;
    }

    public string? ApiType => apiType;
    public bool AlwaysInclude => alwaysInclude;
}