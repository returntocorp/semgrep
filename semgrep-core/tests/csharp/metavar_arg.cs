public class MetaVar
{
    public static void Main()
    {
        // ERROR:
        Foo(1, 2);

        // ERROR:
        Foo(int.MaxValue,
            2);

        // ERROR:
        Foo(int.Parse("3"), // comment
            2);

        // ERROR:
        Foo(1 + 1, 2);

        Foo(1, 2, 3);
    }

    private static void Foo(int a, int b, int c = 3)
    {
    }
}