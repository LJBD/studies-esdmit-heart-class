__author__ = 'Krystian'

# Static const table
# TODO: Gdzie to umiescic?!
svm_type_table = []
svm_type_table.append("c_svc")
svm_type_table.append("nu_svc")
svm_type_table.append("one_class")
svm_type_table.append("epsilon_svr")
svm_type_table.append("nu_svr")
svm_type_table.append(None)
# TODO: Gdzie to umiescic?!
kernel_type_table = []
kernel_type_table.append("linear")
kernel_type_table.append("polynomial")
kernel_type_table.append("rbf")
kernel_type_table.append("sigmoid")
kernel_type_table.append("precomputed")
kernel_type_table.append(None)


from enum import Enum
from Kernel import *


class SVMTypes(Enum):
    C_SVC = 0
    NU_SVC = 1
    ONE_CLASS = 2
    EPSILON_SVR = 3
    NU_SVR = 4

# Cos co ma przypominac strukture. Nie wiem czy tak to sie robi
class svm_parameter:
    weight_label = []  # int - for C_SVC
    weight = []  # double - for C_SVC

    def __init__(self):
        self.svm_type = 0  # int
        self.kernel_type = 0  # int
        self.degree = 0  # int - for poly
        self.gamma = 0  # double - for poly/rbf/sigmoid
        self.coef0 = 0  # double - for poly/sigmoid
        # these are for training only
        self.cache_size = 0  # double - in MB
        self.eps = 0  # double - stopping criteria
        self.C = 0  # double - for C_SVC, EPSILON_SVR and NU_SVR
        self.nr_weight = 0  # int - for C_SVC
        self.nu = 0  # double - for NU_SVC, ONE_CLASS, and NU_SVR
        self.p = 0  # double - for EPSILON_SVR
        self.shrinking = 0  # int - use the shrinking heuristics
        self.probability = 0  # int - do probability estimates


class svm_node:
    def __init__(self, idx, val):
        self.index = idx
        self.value = val


# Cos co ma przypominac strukture. Nie wiem czy tak to sie robi
class svm_model:
    rho = []  # double - constants in decision functions (rho[k*(k-1)/2])
    label = []  # int - label of each class (label[k])
    nSV = []  # int - number of SVs for each class (nSV[k])
    probA = []  # double - pariwise probability information
    probB = []
    param = svm_parameter()  # struct - parameters
    sv_indices = []  # int - sv_indices[0,...,nSV-1] are values in [1,...,num_traning_data] to indicate SVs in the training set

    def __init__(self):
        self.l = None
        self.sv_indices = None
        self.sv_coef = None  # Matrix (double) - coefficients for SVs in decision functions (sv_coef[k-1][l])
        self.SV = None  # Matric (svm_node) - SVs (SV[l])
        self.free_sv = None  # (int) 1 if svm_model is created by svm_load_model
        # 0 if svm_model is created by svm_train


# Funkcja wczytuje jedno slowo
# dziala jak FSCANF w projekcie wzorcowym
def GetNextWord(fp):
    word = ''
    c = fp.read(1)
    while c == '\n' or c == ' ': c = fp.read(1)
    while True:
        word += c
        c = fp.read(1)
        if c == '\n' or c == ' ' or c == '':
            break

    fp.seek(fp.tell() - 1)
    return word


def read_model_header(fp, model):
    cmd = ''
    while cmd != None:

        cmd = GetNextWord(fp)

        if cmd == "svm_type":
            cmd = GetNextWord(fp)
            for i in range(0, svm_type_table.__len__()):
                if svm_type_table[i] == cmd:
                    model.param.svm_type = i
                    break
                if svm_type_table[i] == None:
                    print "ERROR: unknown svm type - ", cmd
                    return False

        elif cmd == "kernel_type":
            cmd = GetNextWord(fp)
            for i in range(0, kernel_type_table.__len__()):
                if kernel_type_table[i] == cmd:
                    model.param.kernel_type = i
                    break
                if kernel_type_table[i] == None:
                    print "ERROR: unknown kernel function."
                    return False

        elif cmd == "degree":
            cmd = GetNextWord(fp)
            model.param.degree = int(cmd)

        elif cmd == "gamma":
            cmd = GetNextWord(fp)
            model.param.gamma = float(cmd)

        elif cmd == "coef0":
            cmd = GetNextWord(fp)
            model.param.coef0 = float(cmd)

        elif cmd == "nr_class":
            cmd = GetNextWord(fp)
            model.nr_class = int(cmd)

        elif cmd == "total_sv":
            cmd = GetNextWord(fp)
            model.l = int(cmd)

        elif cmd == "rho":
            n = model.nr_class * (model.nr_class - 1) / 2
            for i in range(0, n):
                cmd = GetNextWord(fp)
                model.rho.append(float(cmd))  # Nie ma double?

        elif cmd == "label":
            n = model.nr_class
            for i in range(0, n):
                cmd = GetNextWord(fp)
                model.label.append(int(cmd))

        elif cmd == "probA":
            n = model.nr_class * (model.nr_class - 1) / 2;
            for i in range(0, n):
                cmd = GetNextWord(fp)
                model.probA.append(float(cmd))

        elif cmd == "probB":
            n = model.nr_class * (model.nr_class - 1) / 2;
            for i in range(0, n):
                cmd = GetNextWord(fp)
                model.probB.append(float(cmd))

        elif cmd == "nr_sv":
            for i in range(0, int(model.nr_class)):
                cmd = GetNextWord(fp)
                model.nSV.append(int(cmd))

        elif cmd == "SV":
            while True:
                c = fp.read(1)
                if c == '\n' or c == '':
                    break
            break

        else:
            print "ERROR: Unknown text in model file:", cmd
            return False

    return True


def svm_load_model(model_file_name):
    try:
        fp = open(model_file_name, "rb")

        # read parameters
        model = svm_model()

        # read header
        if read_model_header(fp, model) == False:
            print "ERROR: fscanf failed to read model"
            # TODO: return None

        # read sv_coef and SV
        elements = 0
        pos = long(fp.tell())

        line = readline(fp)
        while line != None:
            p = line.split(':')
            elements += p.__len__() - 1
            line = readline(fp)
        elements += model.l
        fp.seek(pos)

        m = model.nr_class - 1
        l = model.l

        # Policz ile tych zestawow wartosci jest w pliku
        # bo nie wiem czy zawsze jest 16
        line = readline(fp)
        p = line.split(' ')
        for i in range(0, p.__len__()):
            if p[i].__contains__(':'): max = i
        fp.seek(pos)

        model.sv_coef = [[None for i in range(l)] for j in range(m)]
        model.SV = [[None for i in range(max)] for j in range(l)]

        for i in range(0, l):
            line = readline(fp)
            p = line.split(' ')

            for k in range(0, m):
                model.sv_coef[k][i] = round(float(p[k]), 6)

            for j in range(m, max + 1):
                k = p[j].split(':')
                idx = int(k[0])
                val = float(k[1])
                model.SV[i][j - m] = svm_node(idx, val)

        model.free_sv = 1

        return model

    except IOError:
        print "Could not open", model_file_name
        raw_input("Press Enter to continue...")
        # TODO: return None


def readline(fp):
    line = ''
    while True:
        c = fp.read(1)
        if c == '':
            return None
        if c == '\n':
            break
        else:
            line += c
    return line

def svm_predict(model, x):
    dec_values = []

    if model.param.svm_type == SVMTypes.ONE_CLASS or model.param.svm_type == SVMTypes.EPSILON_SVR or model.param.svm_type == SVMTypes.NU_SVR:
        sv_coef = model.sv_coef[0]
    else:
        nr_class = model.nr_class
        l = model.l
        kvalue = []
        for i in range(0,l):
            kvalue.append(k_function(x, model.SV[i], model.param))

    return None ######NIE SKONCZONE########


