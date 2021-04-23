namespace BB84 {

    //open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Logical;


    @EntryPoint()
    operation Start() : (Bool, Bool[], Bool[]) {
            
        let result1 = RunBB84Protocol(32, 0.0);
        //Message("Running the protocol for 256 bit key with eavesdropping probability 1 resulted in " + (result1 ? "succcess" | "failure"));
        return result1;
    }

    operation RunBB84Protocol(expectedKeyLength : Int, eavesdropperProbability : Double) : (Bool, Bool[], Bool[]) {
        let chunk = 16;

        // we want to transfer 4n + 𝛿 required bits
        // n = expectedKeyLength
        // chunk = amount of qubits to allocate and send in a single roundtrip
        // 𝛿 = extra bits in case the low sample size causes us to end up with less than required bits
        // at the end of the protocl execution. In our case we assume 𝛿 = 2 * chunk (32)
        let roundtrips = (4 * expectedKeyLength + 2 * chunk) / chunk;
        
        mutable aliceValues = new Bool[0];
        mutable aliceBases = new Bool[0];
        mutable bobResults = new Bool[0];
        mutable bobBases = new Bool[0];
        
        for (roundtrip in 0..roundtrips-1) {
            using (qubits = Qubit[chunk]) {
            
            // continue with the protocol 
            // prepare Alice's qubits
            for (qubit in qubits) {
            
                // Alice chooses random bit
                let valueSelected = DrawRandomBool(0.5);
                if (valueSelected) { X(qubit); }
                set aliceValues += [valueSelected];
            
                // Alice chooses random basis by drawing a random bit
                // 0 will represent |0> and |1> computational (PauliZ) basis
                // 1 will represent |-> and |+> Hadamard (PauliX) basis
                let aliceBasisSelected = DrawRandomBool(0.5);
                if (aliceBasisSelected) { H(qubit); }
                set aliceBases += [aliceBasisSelected];
            }
            //eavesdropper!!!
            for (qubit in qubits) {
                let shouldEavesdrop = DrawRandomBool(eavesdropperProbability);
                if (shouldEavesdrop) {
                    let eveBasisSelected = DrawRandomBool(0.5);
                    let eveResult = Measure([eveBasisSelected ? PauliX | PauliZ], [qubit]);
                }
            }
            for (qubit in qubits) {
                // Bob chooses random basis by drawing a random bit
                // 0 will represent PauliZ basis
                // 1 will represent PauliX basis
                let bobBasisSelected = DrawRandomBool(0.5);
                set bobBases += [bobBasisSelected];
                let bobResult = Measure([bobBasisSelected ? PauliX | PauliZ], [qubit]);
                set bobResults += [ResultAsBool(bobResult)];
                Reset(qubit);
            }

            }
        } // End for
        Message("Comparing bases....");
        mutable aliceValuesAfterBasisComparison = new Bool[0];
        mutable bobValuesAfterBasisComparison = new Bool[0];
        
        // compare bases and pick shared results
        for (i in 0..Length(aliceValues)-1) {
            // if Alice and Bob used the same basis
            // they can use the corresponding bit
            if (aliceBases[i] == bobBases[i]) {
                set aliceValuesAfterBasisComparison += [aliceValues[i]];
                set bobValuesAfterBasisComparison += [bobResults[i]];
            }
        }
        Message("Bases compared.");
        Message("Performing eavesdropping check....");
        // select a random bit of every 2 bits for eavesdropping check
        mutable eavesdropppingIndices = new Int[0];
        let chunkedValues = Chunks(2, RangeAsIntArray(IndexRange(aliceValuesAfterBasisComparison)));
        for (i in IndexRange(chunkedValues)) {
            if (Length(chunkedValues[i]) == 1) {
                set eavesdropppingIndices += [chunkedValues[i][0]];
            } else {
                set eavesdropppingIndices += [DrawRandomBool(0.5) ? chunkedValues[i][0] | chunkedValues[i][1]];
            }
        }
        // compare results on eavesdropping check indices
        mutable differences = 0;
        for (i in eavesdropppingIndices) {
        // if Alice and Bob get different result, but used same basis
        // it means that there must have been an eavesdropper (assuming perfect communication)
            if (aliceValuesAfterBasisComparison[i] != bobValuesAfterBasisComparison[i]) {
                set differences += 1;
            }
        }
        let errorRate = IntAsDouble(differences)/IntAsDouble(Length(eavesdropppingIndices));
        // remove indices used for eavesdropping check from comparison
        let aliceKey = Exclude(eavesdropppingIndices, aliceValuesAfterBasisComparison);
        let bobKey = Exclude(eavesdropppingIndices, bobValuesAfterBasisComparison);
        Message($"Error rate: {errorRate*IntAsDouble(100)}%");
        if (errorRate > 0.0) {
            Message($"Eavesdropper detected! Aborting the protocol");
            return (false, aliceKey, bobKey);
        } else {
            Message($"No eavesdropper detected.");
        }

        
        Message($"Alice's key: {(aliceKey)} | key length: {IntAsString(Length(aliceKey))}");
        Message($"Bob's key:   {(bobKey)} | key length: {IntAsString(Length(bobKey))}");
        Message("");
        
        let keysEqual = EqualA(EqualB, aliceKey, bobKey);
        Message($"Keys are equal? {keysEqual}");
        if (not keysEqual) {
            Message("Keys are not equal, aborting the protocol");
            return (false, aliceKey, bobKey);
        }
        
        if (Length(aliceKey) < expectedKeyLength) {
            Message("Key is too short, aborting the protocol");
            return (false, aliceKey, bobKey);
        }
        
        Message("");
        let trimmedKey = aliceKey[0..expectedKeyLength-1];
        Message($"Final trimmed {expectedKeyLength}bit key: {(trimmedKey)}");

        return (true, aliceKey, bobKey);

}
}
