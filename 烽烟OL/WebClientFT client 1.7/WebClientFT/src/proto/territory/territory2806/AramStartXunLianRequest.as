package proto.territory.territory2806 {
	import com.netease.protobuf.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.errors.IOError;
	// @@protoc_insertion_point(imports)
	// @@protoc_insertion_point(class_metadata)
	public final class AramStartXunLianRequest extends Message implements IExternalizable {
		public var id:int;
		public var type:int;
		public var funType:int;
		public var funId:int;
		public function writeExternal(output:IDataOutput):void {
			WriteUtils.writeTag(output, WireType.VARINT, 1);
			WriteUtils.write_TYPE_INT32(output, id);
			WriteUtils.writeTag(output, WireType.VARINT, 2);
			WriteUtils.write_TYPE_INT32(output, type);
			WriteUtils.writeTag(output, WireType.VARINT, 3);
			WriteUtils.write_TYPE_INT32(output, funType);
			WriteUtils.writeTag(output, WireType.VARINT, 4);
			WriteUtils.write_TYPE_INT32(output, funId);
		}
		public function readExternal(input:IDataInput):void {
			var idCount:uint = 0;
			var typeCount:uint = 0;
			var funTypeCount:uint = 0;
			var funIdCount:uint = 0;
			while (input.bytesAvailable != 0) {
				var tag:Tag = ReadUtils.readTag(input);
				switch (tag.number) {
				case 1:
					if (idCount != 0) {
						throw new IOError('Bad data format.');
					}
					++idCount;
					id = ReadUtils.read_TYPE_INT32(input);
					break;
				case 2:
					if (typeCount != 0) {
						throw new IOError('Bad data format.');
					}
					++typeCount;
					type = ReadUtils.read_TYPE_INT32(input);
					break;
				case 3:
					if (funTypeCount != 0) {
						throw new IOError('Bad data format.');
					}
					++funTypeCount;
					funType = ReadUtils.read_TYPE_INT32(input);
					break;
				case 4:
					if (funIdCount != 0) {
						throw new IOError('Bad data format.');
					}
					++funIdCount;
					funId = ReadUtils.read_TYPE_INT32(input);
					break;
				default:
					ReadUtils.skip(input, tag.wireType);
				}
			}
			if (idCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (typeCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (funTypeCount != 1) {
				throw new IOError('Bad data format.');
			}
			if (funIdCount != 1) {
				throw new IOError('Bad data format.');
			}
		}
	}
}
