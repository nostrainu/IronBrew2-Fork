namespace IronBrew2.Obfuscator
{
	public class ObfuscationSettings
	{
		public bool EncryptStrings;
		public bool EncryptImportantStrings;
		public bool ControlFlow;
		public bool BytecodeCompress;
		public int DecryptTableLen;
		public bool PreserveLineInfo;
		public bool Mutate;
		public bool SuperOperators;
		public int MaxMiniSuperOperators;
		public int MaxMegaSuperOperators;
		public int MaxMutations;
		
		public ObfuscationSettings()
		{
			EncryptStrings = false;
			EncryptImportantStrings = false;
			ControlFlow = false;
			BytecodeCompress = true;
			DecryptTableLen = 500;
			PreserveLineInfo = false;
			Mutate = false;
			SuperOperators = false;
			MaxMegaSuperOperators = 120;
			MaxMiniSuperOperators = 120;
			MaxMutations = 200;
		}
	}
}